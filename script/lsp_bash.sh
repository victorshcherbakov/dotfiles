#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed bash-language-server
	exit $?
fi

if [ ! -x "$(command -v snap)" ]; then
	echo "'snap' is required."
	exit 1
fi

sudo snap install bash-language-server --classic
if [[ $? -ne 0 ]]; then
	exit 1
fi

sudo snap refresh bash-language-server
exit $?
