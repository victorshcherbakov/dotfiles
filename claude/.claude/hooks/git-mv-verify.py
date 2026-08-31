#!/usr/bin/env python3
"""PostToolUse(Bash): after a `git mv`, put the resulting rename state in context.

A move git recorded as delete+add instead of a rename is easy to miss while it
is still cheap to fix, so every `git mv` gets the working-tree status and the
list of staged renames appended to the turn as additional context.

Python rather than the inline jq one-liner this replaces: jq is not installed on
Windows, where hooks run through Git Bash.
"""
from __future__ import annotations

import json
import subprocess
import sys

HEADER = "git mv: verify moved files show R (rename), not D+add:"
RENAMES_HEADER = "--- staged renames (diff --cached -M --diff-filter=R) ---"


def git(*args: str) -> str:
    try:
        result = subprocess.run(
            ["git", *args], capture_output=True, text=True, timeout=10,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout if result.returncode == 0 else ""


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        return 0

    command = (payload.get("tool_input") or {}).get("command") or ""
    if "git mv" not in command:
        return 0

    context = "\n".join([
        HEADER,
        git("status", "--short", "-uno").rstrip("\n"),
        RENAMES_HEADER,
        git("diff", "--cached", "-M", "--diff-filter=R", "--name-status").rstrip("\n"),
    ])

    json.dump({
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": context,
        }
    }, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
