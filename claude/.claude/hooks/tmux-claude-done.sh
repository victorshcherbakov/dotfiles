#!/usr/bin/env bash
# Stop hook: mark the tmux window this session runs in, so its tab in the
# status line pulses until the window is selected (the @claude_done block at the
# end of ~/.tmux.conf draws the pulse and clears the mark).
#
# The window you are looking at is not marked: tmux clears the mark only when a
# window becomes current, so a mark set on the current one would start pulsing
# the moment you leave it.
#
# Outside tmux (and on Windows, where tmux is absent) this does nothing.

[ -n "${TMUX_PANE-}" ] && command -v tmux >/dev/null 2>&1 || exit 0

shown=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{window_active},#{session_attached}}' 2>/dev/null) || exit 0
[ "$shown" = 1 ] && exit 0

tmux set-option -w -t "$TMUX_PANE" @claude_done 1 2>/dev/null
exit 0
