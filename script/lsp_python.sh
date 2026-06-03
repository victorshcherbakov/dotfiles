#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -f "/etc/arch-release" ]]; then
	# pyright lives in the AUR; ensure the yay helper first.
	/bin/bash "${script_dir}/yay.sh" || exit $?
	yay -S --needed pyright
	exit $?
fi

# Linux Mint: pyright is distributed as a snap; ensure snapd first.
if [ ! -x "$(command -v snap)" ]; then
	/bin/bash "${script_dir}/snap.sh" || exit $?
fi

sudo snap install pyright --classic
if [[ $? -ne 0 ]]; then
	exit 1
fi

sudo snap refresh pyright
exit $?
