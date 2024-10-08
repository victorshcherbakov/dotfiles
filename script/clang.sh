#!/bin/bash

MAJOR_VERSION="18"

if [[ -f "/etc/arch-release" ]]; then
	echo "TODO: install clang"
	sudo pacman -S --needed lld
	sudo pacman -S --needed lldb
	exit 1
else
	sudo apt install "clang-$MAJOR_VERSION"
	sudo apt install "clang-tidy-$MAJOR_VERSION"
	sudo apt install "clangd-$MAJOR_VERSION"
	sudo apt install "clang-format-$MAJOR_VERSION"
	sudo apt install "clang-tools-$MAJOR_VERSION"
	sudo apt install "lld-$MAJOR_VERSION"
	sudo apt install "lldb-$MAJOR_VERSION"
fi

exit $?
