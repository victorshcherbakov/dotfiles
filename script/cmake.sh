#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed cmake
else
	sudo apt install cmake
fi

exit $?
