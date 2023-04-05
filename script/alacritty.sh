#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed alacritty
	exit $?
fi

sudo add-apt-repository -r ppa:aslatter/ppa
if [[ $? -ne 0 ]]; then
	exit $?
fi

sudo add-apt-repository ppa:aslatter/ppa
if [[ $? -ne 0 ]]; then
	exit $?
fi

sudo apt update
sudo apt install alacritty

exit $?
