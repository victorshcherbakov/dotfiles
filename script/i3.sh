#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed i3 rofi polybar
	exit $?
fi

echo "TODO: install i3 rofi polybar"

exit 1
