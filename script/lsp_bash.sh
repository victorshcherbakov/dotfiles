#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed bash-language-server
	exit $?
fi

echo "TODO: install bash-language-server"

exit 1
