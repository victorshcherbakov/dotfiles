#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	yay -S --needed pyright
	exit $?
fi

echo "TODO: install Python Language Server"

exit 1
