#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed fzf
	exit $?
fi

shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$shell "$script_dir/install_from_github_archive.sh" jesseduffield lazygit _Linux_x86_64.tar.gz
exit $?
