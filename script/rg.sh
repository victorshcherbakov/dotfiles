#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed ripgrep
else
	sudo apt install ripgrep
fi

exit $?
