#!/usr/bin/env python3
"""Warn the user once per Claude Code session when total context reaches a threshold.

Reads the hook payload (JSON) from stdin, tails the session transcript for the
latest message.usage, sums input + cache_read + cache_creation tokens, and fires
notify-send + paplay if the threshold is crossed. A marker file in /tmp guarantees
one notification per session_id.
"""
import json
import os
import subprocess
import sys

THRESHOLD = 250_000
SOUND = "/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    transcript = payload.get("transcript_path")
    session_id = payload.get("session_id") or "unknown"
    if not transcript or not os.path.isfile(transcript):
        return 0

    marker = f"/tmp/claude-ctx-warned-{session_id}"
    if os.path.exists(marker):
        return 0

    last_usage = None
    try:
        with open(transcript, "rb") as fp:
            for raw in fp:
                try:
                    record = json.loads(raw)
                except Exception:
                    continue
                usage = (record.get("message") or {}).get("usage")
                if usage:
                    last_usage = usage
    except Exception:
        return 0

    if not last_usage:
        return 0

    total = (
        int(last_usage.get("input_tokens") or 0)
        + int(last_usage.get("cache_read_input_tokens") or 0)
        + int(last_usage.get("cache_creation_input_tokens") or 0)
    )

    if total < THRESHOLD:
        return 0

    # Mark first so concurrent hook invocations can't double-fire.
    try:
        open(marker, "w").close()
    except Exception:
        pass

    cwd_label = os.path.basename(payload.get("cwd") or os.getcwd()) or "?"
    title = "Claude Code: context 250k"
    body = f"Session {session_id[:8]} ({cwd_label}) reached {total:_} tokens".replace("_", " ")

    subprocess.Popen(
        ["notify-send", "-u", "critical", "-a", "Claude Code", title, body],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    if os.path.isfile(SOUND):
        subprocess.Popen(
            ["paplay", SOUND],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
