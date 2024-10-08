#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed yay
	exit $?
fi

exit 0
