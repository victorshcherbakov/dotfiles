#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed bash-language-server
	exit $?
fi

# Linux Mint: bash-language-server is distributed as a snap; ensure snapd first.
if [ ! -x "$(command -v snap)" ]; then
	/bin/bash "${script_dir}/snap.sh" || exit $?
fi

sudo snap install bash-language-server --classic
if [[ $? -ne 0 ]]; then
	exit 1
fi

sudo snap refresh bash-language-server
exit $?
