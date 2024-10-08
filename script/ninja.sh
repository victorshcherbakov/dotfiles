#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed ninja
else
	sudo apt install ninja-build
fi

exit $?
