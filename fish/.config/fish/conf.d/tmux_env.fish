# A pane keeps the environment it was spawned with, but tmux rewrites the
# session environment (update-environment) on every client attach. A pane
# created while a non-X client was attached (tty, ssh) never gets DISPLAY back,
# so clipboard tools (xclip, Claude Code image paste) fail there forever.
# Re-read the display variables from the session before each command.
if status is-interactive; and set -q TMUX
	function __tmux_sync_display_env --on-event fish_preexec
		for line in (tmux show-environment 2>/dev/null)
			switch $line
				case 'DISPLAY=*' 'XAUTHORITY=*' 'WAYLAND_DISPLAY=*' 'XDG_SESSION_TYPE=*'
					set -l kv (string split -m1 = -- $line)
					set -gx $kv[1] $kv[2]
				case -DISPLAY -XAUTHORITY -WAYLAND_DISPLAY -XDG_SESSION_TYPE
					set -e (string sub -s 2 -- $line)
			end
		end
	end
end
