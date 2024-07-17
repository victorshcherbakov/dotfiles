#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed mold
	exit $?
fi

echo "TODO: install mold"

exit 1
