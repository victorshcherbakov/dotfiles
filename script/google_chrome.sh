#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	echo "More info here: https://www.omglinux.com/install-google-chrome-manjaro-linux/"
	pamac build google-chrome
	exit $?
fi

echo "TODO: install google chrome"

exit 1
