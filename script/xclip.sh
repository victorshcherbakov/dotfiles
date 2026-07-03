#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed xclip
else
	sudo apt install xclip
fi

exit $?
