#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed python-pip
else
	sudo apt install python3-pip
fi

exit $?
