#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed jq
else
	sudo apt install jq
fi

exit $?
