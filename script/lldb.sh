#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed lldb
	exit $?
fi

echo "TODO: install lldb"

exit 1
