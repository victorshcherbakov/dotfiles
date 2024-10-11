#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	yay -S --needed pyright
	exit $?
fi

if [ ! -x "$(command -v snap)" ]; then
	echo "'snap' is required."
	exit 1
fi

sudo snap install pyright --classic
if [[ $? -ne 0 ]]; then
	exit 1
fi

sudo snap refresh pyright
exit $?
