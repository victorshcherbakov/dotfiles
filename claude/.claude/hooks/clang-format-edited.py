#!/usr/bin/env python3
"""PostToolUse hook: clang-format only the file Claude just edited.

Fires after Edit/Write/MultiEdit. Reads the tool payload from stdin, takes
tool_input.file_path, and reformats only the lines changed vs the git index
(the whole file if it is a brand-new untracked file). Scoping to the single
edited file is the whole point: the manual /format skill walks
`git diff --name-only` over the entire tree and would reformat unrelated
uncommitted work; this hook never touches a file Claude did not edit.

Never blocks the edit — any problem (no clang-format, not a git repo, parse
failure, timeout) exits 0 silently. Writes the file back only when formatting
actually changes bytes, to avoid needless mtime churn.
"""
import json
import os
import re
import shutil
import subprocess
import sys

CPP_EXTENSIONS = (".cpp", ".cc", ".cxx", ".c", ".h", ".hpp", ".hxx")
HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", re.MULTILINE)


def git(repo_dir, *args):
    return subprocess.run(
        ["git", "-C", repo_dir, *args], capture_output=True, text=True, timeout=10
    )


def main() -> int:
    payload = json.load(sys.stdin)
    file = (payload.get("tool_input") or {}).get("file_path", "")
    if not file or not file.endswith(CPP_EXTENSIONS) or not os.path.isfile(file):
        return 0

    clang_format = shutil.which("clang-format")
    if not clang_format:
        return 0

    repo_dir = os.path.dirname(file) or "."
    if git(repo_dir, "rev-parse", "--show-toplevel").returncode != 0:
        return 0

    diff = git(repo_dir, "diff", "-U0", "--", file).stdout
    line_args = []
    for m in HUNK_RE.finditer(diff):
        start = int(m.group(1))
        count = int(m.group(2)) if m.group(2) is not None else 1
        count = count or 1  # a pure-deletion hunk (+c,0): format the surviving line
        line_args.append(f"--lines={start}:{start + count - 1}")

    if not line_args:
        # No unstaged hunks. Format the whole file only when it is brand new
        # (untracked); an already-tracked, unchanged file needs nothing.
        if git(repo_dir, "ls-files", "--error-unmatch", "--", file).returncode == 0:
            return 0

    formatted = subprocess.run(
        [clang_format, *line_args, file], capture_output=True, timeout=20
    )
    if formatted.returncode != 0:
        return 0

    with open(file, "rb") as f:
        original = f.read()
    if formatted.stdout == original:
        return 0
    with open(file, "wb") as f:
        f.write(formatted.stdout)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)
