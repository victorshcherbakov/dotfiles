#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed lazygit
	exit $?
fi

shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# The asset name is matched as a regex, and upstream switched "_Linux_" to
# "_linux_" - accept either. Leave the dots unescaped: the installer detects
# the archive format by globbing this argument against *.tar.gz.
$shell "$script_dir/install_from_github_archive.sh" jesseduffield lazygit _[Ll]inux_x86_64.tar.gz
exit $?
