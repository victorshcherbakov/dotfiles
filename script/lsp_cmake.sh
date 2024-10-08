#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	yay -S --needed cmake-language-server
	exit $?
fi

echo "TODO: install Cmake Language Server"
echo "from https://github.com/regen100/cmake-language-server"
# Don't interrupt installation
exit 0
