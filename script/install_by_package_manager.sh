#!/bin/bash

if [[ $# -eq 0 ]]; then
	echo "Please use this script like:"
	echo "${0##*/} one_app"
	echo "${0##*/} curl wget firefox"
	exit 1
fi

# TODO: detect a package manager
pm=apt

if ! [[ -x "$(command -v $pm)" ]]; then
	>&2 echo "The package manager \`$pm\` isn't found. Please update this script \`${0##*/}\`."
	>&2 echo "Error occured. Exit"
	exit 1
fi

# Skipping what is already there keeps every `make install-*` runnable without
# a sudo password when its deps are present: the GitHub-release installers ask
# for curl/jq/tar on every run, and apt would prompt even with nothing to do.
# `dpkg -s` alone is not enough - a purged package whose config files remain
# still reports a status line - so the state has to say "install ok installed".
installed() {
	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed' && return 0
	# Fall back to the binary: a tool installed outside apt (a GitHub .deb under
	# another package name, a snap) must not be overwritten by the apt version.
	command -v "$1" &>/dev/null
}

for app in $@; do
	if installed "$app"; then
		echo "Skip \`$app\`: already installed"
		continue
	fi
	sudo $pm install $app
	if [[ $? -ne 0 ]]; then
		>&2 echo "The installation for \`$app\` has been interrupted."
		>&2 echo "Error occured ($?). Exit"
		exit 1
	fi
done

exit 0
