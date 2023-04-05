#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed subversion
else
	sudo apt install subversion
fi

exit $?
