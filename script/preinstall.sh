#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	# TODO: check for Manjaro
	if [[ -x "$(command -v yay)" ]]; then
		sudo yay -Syu
	else
		sudo pacman -Syu
	fi
else
	SUPPORTED_ID="linuxmint"
	SUPPORTED_VERSION="22"

	id=$(sed -n 's/^ID=\(.*\)/\1/p' /etc/os-release)
	version=$(sed -n 's/^VERSION_ID="\([^"]*\)"/\1/p' /etc/os-release)

	if [[ "$id" == "$SUPPORTED_ID" && "$version" == "$SUPPORTED_VERSION" ]]; then
		sudo apt update && sudo apt upgrade
	else
		echo "Only these ID=$SUPPORTED_ID and VERSION_ID=$SUPPORTED_VERSION are supported."
		echo "You have others: ID=$id and VERSION_ID=$version."
		exit 1
	fi
fi

exit $?
