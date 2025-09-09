#!/bin/bash

MAJOR_VERSION="20"

if [[ -f "/etc/arch-release" ]]; then
	echo "TODO: install clang"
	sudo pacman -S --needed lld
	sudo pacman -S --needed lldb
	exit 1
else
	sudo apt install "clang-$MAJOR_VERSION" "clang-tidy-$MAJOR_VERSION" "clangd-$MAJOR_VERSION" "clang-format-$MAJOR_VERSION" "clang-tools-$MAJOR_VERSION" "lld-$MAJOR_VERSION" "lldb-$MAJOR_VERSION"
fi

echo "Remove libclang-VERSION-dev"
echo "Remove libclang-common-VERSION-dev"
echo "Remove libclang-cppVERSION"
echo "Remove libclang-rt-VERSION-dev"
echo "Remove libclang1-VERSION"
echo "Remove libllvmVERSION"
# sudo apt remove libclang-18-dev libclang-common-18-dev libclang-cpp18 libclang-rt-18-dev libclang1-18
# sudo apt remove clang-18 clang-tidy-18 clangd-18 clang-format-18 clang-tools-18 lld-18 lldb-18

exit $?
