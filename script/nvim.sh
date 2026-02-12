#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed neovim
	exit $?
fi

shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
archive_name=$(curl -s -H 'Accept: application/json' \
	https://api.github.com/repos/neovim/neovim/releases/latest \
	| jq -r '.assets[].name | select(test("nvim-linux.*x86_64\\.tar\\.gz"))')

if [[ -z "${archive_name}" ]]; then
	>&2 echo "Could not find a matching tar.gz asset for linux x86_64"
	exit 1
fi

$shell "${script_dir}/install_from_github_archive.sh" neovim neovim "${archive_name}"
if [[ $? -ne 0 ]]; then
	exit $?
fi

path_tmp="/tmp/nvim_installation_$(date +%s)"
# Detect extracted directory dynamically instead of hardcoding the name.
path_from=$(find "${HOME}/.local/bin" -maxdepth 1 -type d -name "nvim-linux*" | head -1)

if [[ -z "${path_from}" ]]; then
	>&2 echo "Could not find extracted neovim directory in ${HOME}/.local/bin"
	exit 1
fi

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
