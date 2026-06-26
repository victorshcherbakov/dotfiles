#!/usr/bin/env python3
"""Claude Code status line: working dir, git branch, model, and context tokens used.

Reads the status-line payload (JSON) from stdin, tails the session transcript for the
latest message.usage, and prints `input + cache_read + cache_creation` tokens - the same
figure /context reports as occupied context. ASCII only (the terminal does not render
emoji). The token figure is colored by how close it is to a full context.
"""
import json
import os
import subprocess
import sys

# Color thresholds for the context figure (tokens).
YELLOW_AT = 400_000
RED_AT = 700_000


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

    print(" | ".join(parts))


if __name__ == "__main__":
    main()
