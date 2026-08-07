#!/usr/bin/env python3
"""Claude Code status line: working dir, git branch, model, context tokens, session usage.

Trailing fields: `sess N%` is the 5h-limit usage percent (cached, refreshed out of band by
usage-refresh.sh), `reset Xh YYm` counts down to when that limit resets - a live figure
derived from a cached epoch, so it ticks down between the ~120s cache refreshes - and
`week N%` is the weekly all-models limit from the same refresh.

Reads the status-line payload (JSON) from stdin, tails the session transcript for the
latest message.usage, and prints `input + cache_read + cache_creation` tokens - the same
figure /context reports as occupied context. ASCII only (the terminal does not render
emoji). The token figure is colored by how close it is to a full context.
"""
import json
import os
import subprocess
import sys
import time

# Color thresholds for the context figure (tokens).
YELLOW_AT = 400_000
RED_AT = 700_000

# Cached machine-wide "Current session" usage percent (5h rolling limit), refreshed out of
# band by usage-refresh.sh - too slow (~2s) to query inline on every status-line tick.
USAGE_CACHE = os.path.expanduser("~/.claude/usage-session-cache")
# Epoch of the current session's 5h-limit reset, refreshed alongside USAGE_CACHE.
USAGE_RESET_CACHE = os.path.expanduser("~/.claude/usage-session-reset")
# Weekly (all models) usage percent, written by the same refresh as USAGE_CACHE.
USAGE_WEEK_CACHE = os.path.expanduser("~/.claude/usage-week-cache")
USAGE_REFRESH = os.path.expanduser("~/.claude/hooks/usage-refresh.sh")
USAGE_TTL = 120  # seconds before the cached percent is considered stale and a refresh fires
# Color thresholds for the usage percents.
USAGE_YELLOW_AT = 60
USAGE_RED_AT = 85


def last_usage(transcript_path):
    # Scan only the tail: the latest turn's usage is at the end, and the transcript grows
    # to tens of MB. 1 MB comfortably holds the last record; full-scan only if it does not.
    try:
        size = os.path.getsize(transcript_path)
    except OSError:
        return None

    def scan(from_offset):
        with open(transcript_path, "rb") as fp:
            fp.seek(from_offset)
            blob = fp.read()
        lines = blob.split(b"\n")
        if from_offset > 0 and lines:
            lines = lines[1:]  # drop the partial first line produced by seeking mid-file
        found = None
        for raw in lines:
            if not raw.strip():
                continue
            try:
                record = json.loads(raw)
            except ValueError:
                continue
            usage = (record.get("message") or {}).get("usage")
            if usage:
                found = usage
        return found

    tail_start = max(0, size - 1024 * 1024)
    usage = scan(tail_start)
    if usage is None and tail_start > 0:
        usage = scan(0)
    return usage


def context_tokens(transcript_path):
    usage = last_usage(transcript_path) if transcript_path else None
    if not usage:
        return None
    return (
        int(usage.get("input_tokens") or 0)
        + int(usage.get("cache_read_input_tokens") or 0)
        + int(usage.get("cache_creation_input_tokens") or 0)
    )


def human(n):
    return f"{round(n / 1000)}k" if n >= 1000 else str(n)


def session_usage():
    # Returns the cached percent (or None) and fires a background refresh when the cache is
    # missing or older than the TTL. The refresh detaches and never blocks the status line;
    # its own flock collapses concurrent triggers into one.
    pct = None
    fresh = False
    try:
        pct = int(open(USAGE_CACHE).read().strip())
        fresh = (time.time() - os.path.getmtime(USAGE_CACHE)) < USAGE_TTL
    except (OSError, ValueError):
        pass
    if not fresh and os.access(USAGE_REFRESH, os.X_OK):
        try:
            subprocess.Popen(
                [USAGE_REFRESH],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True,
            )
        except OSError:
            pass
    return pct


def week_usage():
    # Cached weekly percent, or None. No refresh trigger of its own: the same run of
    # usage-refresh.sh that session_usage() fires writes this cache too.
    try:
        return int(open(USAGE_WEEK_CACHE).read().strip())
    except (OSError, ValueError):
        return None


def usage_field(label, pct):
    if pct is None:
        return f"{label} -"
    color = 31 if pct >= USAGE_RED_AT else 33 if pct >= USAGE_YELLOW_AT else 32
    return f"\033[{color}m{label} {pct}%\033[0m"


def session_reset():
    # Seconds until the session limit resets (from the epoch cache), or None if unknown.
    # Clamped at 0: a slightly stale cache can put the reset just in the past between the
    # 120s refreshes, and a negative countdown would read as nonsense.
    try:
        epoch = int(open(USAGE_RESET_CACHE).read().strip())
    except (OSError, ValueError):
        return None
    return max(0, epoch - int(time.time()))


def human_duration(secs):
    hours, minutes = secs // 3600, (secs % 3600) // 60
    return f"{hours}h{minutes:02d}m" if hours else f"{minutes}m"


def git_branch(cwd):
    try:
        result = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=1,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        payload = {}

    cwd = payload.get("cwd") or (payload.get("workspace") or {}).get("current_dir") or os.getcwd()
    model = (payload.get("model") or {}).get("display_name") or (payload.get("model") or {}).get("id")

    parts = [os.path.basename(cwd.rstrip("/")) or cwd]
    branch = git_branch(cwd)
    if branch:
        parts.append(branch)
    if model:
        parts.append(model)

    tokens = context_tokens(payload.get("transcript_path"))
    if tokens is None:
        ctx = "ctx -"
    else:
        color = 31 if tokens >= RED_AT else 33 if tokens >= YELLOW_AT else 32
        ctx = f"\033[{color}mctx {human(tokens)}\033[0m"
    parts.append(ctx)

    parts.append(usage_field("sess", session_usage()))

    remaining = session_reset()
    parts.append("reset -" if remaining is None else f"reset {human_duration(remaining)}")

    parts.append(usage_field("week", week_usage()))

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
