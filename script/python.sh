#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed python
else
	sudo apt install python3
fi

exit $?
