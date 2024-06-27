#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed curl
else
	sudo apt install curl
fi

exit $?
