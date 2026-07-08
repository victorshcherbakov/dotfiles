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
RESET_CACHE="$HOME/.claude/usage-session-reset"
LOCK="$HOME/.claude/usage-session-cache.lock"

exec 9>"$LOCK" || exit 0
flock -n 9 || exit 0

uuid=$(cat /proc/sys/kernel/random/uuid)
out=$(timeout 30 claude -p "/usage" --session-id "$uuid" 2>/dev/null)

for transcript in "$HOME"/.claude/projects/*/"$uuid".jsonl; do
	[ -e "$transcript" ] && rm -f "$transcript"
done

# "Current session: 64% used · resets Jul 8, 1:39pm (Asia/Tomsk)"
line=$(printf '%s\n' "$out" | grep -m1 'Current session:')
pct=$(printf '%s\n' "$line" | grep -oE '[0-9]+%' | grep -oE '[0-9]+')
[ -n "$pct" ] && printf '%s\n' "$pct" >"$CACHE"

# Store the reset moment as an epoch so the status line can render a live countdown
# without re-querying. `date` is fed the displayed TZ and a normalized string
# ("Jul 8, 1:39pm" -> "Jul 8 1:39 pm"); the reset is always <5h out, so an epoch far in
# the past means a Dec->Jan year rollover the string omits - reparse pinned to next year.
reset=$(printf '%s\n' "$line" | sed -n 's/.*resets //p')
if [ -n "$reset" ]; then
	tz=$(printf '%s' "$reset" | grep -oE '\([^)]+\)' | tr -d '()')
	when=$(printf '%s' "$reset" | sed -E 's/ *\([^)]*\)//; s/,//; s/([0-9])(am|pm)/\1 \2/')
	epoch=$(TZ="$tz" date -d "$when" +%s 2>/dev/null)
	if [ -n "$epoch" ] && [ "$epoch" -lt "$(( $(date +%s) - 86400 ))" ]; then
		epoch=$(TZ="$tz" date -d "$when $(( $(date +%Y) + 1 ))" +%s 2>/dev/null)
	fi
	[ -n "$epoch" ] && printf '%s\n' "$epoch" >"$RESET_CACHE"
fi
