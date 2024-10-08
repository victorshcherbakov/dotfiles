#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed telegram-desktop
	exit $?
fi

echo "TODO: install telegram"

exit 1
