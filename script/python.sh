#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed python
	exit $?
fi

echo "TODO: install python"

exit 1
