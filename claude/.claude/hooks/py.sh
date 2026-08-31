#!/usr/bin/env bash
# Run a Python hook with the interpreter that exists on this OS.
#
# Hooks run under Git Bash on Windows, so the shebang would resolve `python3` to
# the Microsoft Store stub (it prints "Python", exits 0 and runs nothing); the
# real interpreter is only reachable through the `py` launcher. Everything in
# settings.json therefore calls Python through this wrapper instead of relying
# on the shebang of the hook itself.
set -u

if [ "${OS-}" = "Windows_NT" ] && command -v py >/dev/null 2>&1; then
	exec py -3 "$@"
fi

exec python3 "$@"
