#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed lld
	exit $?
fi

echo "TODO: install lld"

exit 1
