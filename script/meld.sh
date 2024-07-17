#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed meld
	exit $?
fi

echo "TODO: install meld"

exit 1
