#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed tmux
else
	sudo apt install tmux
fi

exit $?
