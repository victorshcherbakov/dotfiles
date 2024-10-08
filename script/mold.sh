#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed mold
else
	sudo apt install mold
fi

exit $?
