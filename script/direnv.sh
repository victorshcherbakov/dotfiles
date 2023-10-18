#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed direnv
else
	sudo apt install direnv
fi

exit $?
