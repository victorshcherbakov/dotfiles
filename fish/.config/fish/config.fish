#
#  File: config.fish
# Created by Ivan Berdnikov on 06/03/19
#

# vi-keybindings by default
fish_vi_key_bindings

# Enable core dumps by default
ulimit -c unlimited

# Restore "<Ctrl>f" mapping from emacs mode.
for mode in insert default visual
	bind -M $mode \cf forward-char
end

# Fast, cancellable ripgrep + fzf content search
bind \cs fzf_rg

# Supress greetings message.
function fish_greeting
end

# Work around a Muffin >= 6.6.0 regression: it suppresses keyboard focus for a
# window that issues configure(ABOVE) right after mapping (winit, hence
# Alacritty, does), so the window is raised but its shell ignores keystrokes
# until clicked. Re-request activation for our own window on startup. Skipped
# inside tmux: panes inherit ALACRITTY_WINDOW_ID and would yank focus to a
# background window.
if status is-interactive; and set -q ALACRITTY_WINDOW_ID; and not set -q TMUX; and command -q xdotool
	xdotool windowactivate $ALACRITTY_WINDOW_ID &>/dev/null
end

