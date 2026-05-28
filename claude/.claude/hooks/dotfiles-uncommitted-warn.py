#!/usr/bin/env python3
"""Warn via notify-send when the dotfiles repo has uncommitted changes in claude/.

Fires on the Stop event. The claude/ directory is a stow-managed package whose
contents are symlinked into ~/.claude/, so any skill/command/hook/settings.json
that Claude Code writes there shows up as a tracked-or-untracked change in
`git status` of the dotfiles repo. If anything is pending, we remind the user.
"""
import json
import os
import subprocess
import sys

SUBPATH = "claude/"


def find_repo_root() -> str | None:
    # __file__ is reached via a stow symlink in ~/.claude/hooks/. Resolving it
    # gives the real path inside the dotfiles repo wherever it's cloned.
    script_dir = os.path.dirname(os.path.realpath(__file__))
    try:
        out = subprocess.run(
            ["git", "-C", script_dir, "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=3,
        )
    except Exception:
        return None
    if out.returncode != 0:
        return None
    return out.stdout.strip() or None


def main() -> int:
    try:
        json.load(sys.stdin)
    except Exception:
        pass

    repo = find_repo_root()
    if not repo:
        return 0

    try:
        result = subprocess.run(
            ["git", "-C", repo, "status", "--porcelain", "--", SUBPATH],
            capture_output=True,
            text=True,
            timeout=3,
        )
    except Exception:
        return 0

    output = result.stdout.strip()
    if not output:
        return 0

    file_count = len(output.splitlines())
    title = "Dotfiles: uncommitted Claude config"
    body = (
        f"{file_count} change(s) under {SUBPATH} in {repo}\n"
        f"Don't forget to commit."
    )

    try:
        subprocess.run(
            ["notify-send", "-u", "normal", "-i", "dialog-information", title, body],
            timeout=3,
            check=False,
        )
    except Exception:
        pass

    return 0


if __name__ == "__main__":
    sys.exit(main())
