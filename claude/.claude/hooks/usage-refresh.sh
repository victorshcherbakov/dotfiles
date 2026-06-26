#!/usr/bin/env bash
# Refresh the cached "Current session" usage percentage shown in the status line.
#
# `/usage` is only reachable as a slash command, so we run it headlessly. It makes no
# model call (intercepted before the API), and we force a known --session-id so its
# throwaway transcript can be deleted afterwards - the refresh leaves no session behind
# (no history pollution, nothing added to the /usage session count). flock keeps
# concurrent Claude sessions (any directory) to a single refresh; the cache is global
# because the figure is machine-wide, not per-session.
set -u

CACHE="$HOME/.claude/usage-session-cache"
LOCK="$HOME/.claude/usage-session-cache.lock"

exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

uuid=$(cat /proc/sys/kernel/random/uuid)
out=$(timeout 30 claude -p "/usage" --session-id "$uuid" 2>/dev/null)

for transcript in "$HOME"/.claude/projects/*/"$uuid".jsonl; do
	[ -e "$transcript" ] && rm -f "$transcript"
done

pct=$(printf '%s\n' "$out" | grep -m1 -oE 'Current session: [0-9]+%' | grep -oE '[0-9]+')
[ -n "$pct" ] && printf '%s\n' "$pct" >"$CACHE"
