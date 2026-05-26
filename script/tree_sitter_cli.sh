#!/bin/bash

# tree-sitter CLI is required by nvim-treesitter `main` branch to compile parsers.

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed tree-sitter-cli
	exit $?
fi

# Debian / Ubuntu / Linux Mint: no apt package, fetch latest GitHub release.
arch="$(uname -m)"
case "$arch" in
	x86_64) asset_arch="x64" ;;
	aarch64|arm64) asset_arch="arm64" ;;
	*)
		>&2 echo "Unsupported CPU architecture: ${arch}"
		exit 1
		;;
esac

shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$shell "${script_dir}/install_from_github_archive.sh" \
	tree-sitter tree-sitter "-linux-${asset_arch}.gz" tree-sitter
