#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed meld
else
	sudo apt install meld
fi

exit $?
