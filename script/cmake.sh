#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed cmake
    exit $?
fi

echo "TODO: install cmake"

exit 1
