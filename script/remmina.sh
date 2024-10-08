#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed remmina
	sudo pacman -S --needed freerdp
	exit $?
fi

echo "TODO: install remmina and freerdp"
# Don't interrupt installation
exit 0
