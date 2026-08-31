#!/usr/bin/env python3
"""Warn on the desktop when the dotfiles repo has uncommitted changes in claude/.

Fires on the Stop event. The claude/ directory is a stow-managed package whose
contents are symlinked into ~/.claude/ (by stow on Linux, by
script/windows/install-claude.ps1 on Windows), so any skill/command/hook/settings.json
that Claude Code writes there shows up as a tracked-or-untracked change in
`git status` of the dotfiles repo. If anything is pending, we remind the user.

Notifies only when the pending state actually changed since the last
notification: a hash of status+diff is kept in a cache file shared by all
sessions, and a clean tree resets it so the next change notifies again.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys

from notify import notify

SUBPATH = "claude/"
STATE_FILE = os.path.join(
    os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")),
    "dotfiles-uncommitted-warn.hash",
)


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
        # Clean tree: reset the state so the next change notifies again.
        try:
            os.remove(STATE_FILE)
        except OSError:
            pass
        return 0

    # Porcelain output catches file list changes; diff catches content changes
    # within the same file list (untracked file content is not covered).
    try:
        diff = subprocess.run(
            ["git", "-C", repo, "diff", "HEAD", "--", SUBPATH],
            capture_output=True,
            text=True,
            timeout=3,
        ).stdout
    except Exception:
        diff = ""
    state = hashlib.sha256((output + "\n" + diff).encode()).hexdigest()

    try:
        with open(STATE_FILE) as state_file:
            if state_file.read().strip() == state:
                return 0
    except OSError:
        pass

    file_count = len(output.splitlines())
    title = "Dotfiles: uncommitted Claude config"
    body = (
        f"{file_count} change(s) under {SUBPATH} in {repo}\n"
        f"Don't forget to commit."
    )

    notify(title, body)

    try:
        os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
        with open(STATE_FILE, "w") as state_file:
            state_file.write(state)
    except OSError:
        pass

    return 0


if __name__ == "__main__":
    sys.exit(main())
