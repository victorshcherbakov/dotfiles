#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed tmux
else
	sudo apt install tmux
fi

echo "Don't forget install new plugins [`prefix` + <kbd>I</kbd>]."
echo "It also refreshes TMUX environment."
echo "Or update current plugins [`prefix` + <kbd>U</kbd>]"

exit $?
