#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed python-pip
	exit $?
fi

echo "TODO: install python-pip"

exit 1
