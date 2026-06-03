#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -f "/etc/arch-release" ]]; then
	# cmake-language-server lives in the AUR; ensure the yay helper first.
	/bin/bash "${script_dir}/yay.sh" || exit $?
	yay -S --needed cmake-language-server
	exit $?
fi

echo "TODO: install Cmake Language Server"
echo "from https://github.com/regen100/cmake-language-server"
# Don't interrupt installation
exit 0
