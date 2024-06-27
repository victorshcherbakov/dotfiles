#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
    if [ ! -x "$(command -v snap)" ]; then
        echo "'snap' is required."
        exit 1
    fi
	sudo snap install skype
    exit $?
fi

echo "TODO: install skype"

exit 1
