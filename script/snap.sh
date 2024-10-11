#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	exit 1
else
	# Don't forget to remove
	# /etc/apt/preferences.d/nosnap.pref
	sudo apt install snapd
fi

exit $?
