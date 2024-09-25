#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed git-lfs
	exit $?
fi

echo "TODO: install git-lfs"

exit 1
