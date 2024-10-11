#!/bin/bash

if [ ! -x "$(command -v snap)" ]; then
	echo "'snap' is required."
	exit 1
fi

sudo snap install skype
if [[ $? -ne 0 ]]; then
	exit 1
fi

sudo snap refresh skype
exit $?
