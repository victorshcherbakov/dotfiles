#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed git
	exit $?
fi

sudo add-apt-repository -r ppa:git-core/ppa
if [[ $? -ne 0 ]]; then
	exit $?
fi

sudo add-apt-repository ppa:git-core/ppa
if [[ $? -ne 0 ]]; then
	exit $?
fi

sudo apt update
sudo apt install git

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.st status

exit $?
