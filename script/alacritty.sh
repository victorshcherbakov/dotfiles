#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed alacritty
	exit $?
else
	sudo apt install alacritty
fi

exit $?
