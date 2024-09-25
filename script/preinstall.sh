#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	if [[ -x "$(command -v yay)" ]]; then
		sudo yay -Syu
	else
		sudo pacman -Syu
	fi
else
	sudo apt update && sudo apt upgrade 
fi

exit $?
