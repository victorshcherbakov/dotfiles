#!/bin/bash

sudo add-apt-repository 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-15 main'
sudo apt install clang-15 lldb-15 lld-15 clang-tidy-15 clangd-15 clang-format-15 clang-tools-15
exit $?
