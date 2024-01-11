#!/bin/bash

sudo add-apt-repository 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-17 main'
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
sudo apt update
sudo apt install clang-17 lldb-17 lld-17 clang-tidy-17 clangd-17 clang-format-17 clang-tools-17
exit $?
