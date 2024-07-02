#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	yay -S --needed cmake-language-server
	exit $?
fi

echo "TODO: install Cmake Language Server"

exit 1
