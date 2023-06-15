#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed neovim
	exit $?
fi

shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$shell "${script_dir}/install_from_github_archive.sh" neovim neovim nvim-linux64.tar.gz
if [[ $? -ne 0 ]]; then
	exit $?
fi

path_tmp="/tmp/nvim_installation_$(date +%s)"
path_from="${HOME}/.local/bin/nvim-linux64"

mv ${path_from} ${path_tmp}
if [[ $? -ne 0 ]]; then
	>&2 echo "Moving failed, from: ${path_from}, to: ${path_tmp}"
	rm -r ${path_from}
	exit $?
fi

path_to="${HOME}/.local"

cp -f -R ${path_tmp}/* ${path_to}
if [[ $? -ne 0 ]]; then
	>&2 echo "Moving failed, from: ${path_tmp}, to: ${path_to}"
	rm -r ${path_tmp}
	exit $?
fi

rm -r ${path_tmp}

exit $?
