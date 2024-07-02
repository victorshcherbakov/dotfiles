SHELL := /bin/bash
TARGET_DIR := $(HOME)
MKFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

all: install


install: preinstall \
	install-git \
	install-svn \
	install-stow \
	install-fish \
	install-nvim \
	install-gdb \
	install-tmux \
	install-alacritty \
	install-lf \
	install-fzf \
	install-fd \
	install-bat \
	install-rg \
	install-ninja \
	install-lazygit \
	install-direnv \
	install-cmake \
	install-python \
	install-python-pip \
	install-lsp-lua \
	install-lsp-cmake \
	install-lsp-python \
	install-lsp-bash \
	install-lld \
	install-lldb

.PHONY: install-git
install-git: preinstall
	${SHELL} ${MKFILE_DIR}/script/git.sh

.PHONY: install-svn
install-svn: preinstall
	${SHELL} ${MKFILE_DIR}/script/svn.sh

.PHONY: install-stow
install-stow: preinstall
	${SHELL} ${MKFILE_DIR}/script/stow.sh

.PHONY: install-fish
install-fish: preinstall install-stow install-git install-curl
	${SHELL} ${MKFILE_DIR}/script/fish.sh
	stow --target=${TARGET_DIR} fish

.PHONY: install-nvim
install-nvim: preinstall install-stow
	${SHELL} ${MKFILE_DIR}/script/nvim.sh
	stow --target=${TARGET_DIR} nvim

.PHONY: install-gdb
install-gdb: install-stow install-git install-svn
	rm -rf ${HOME}/.local/share/gdb/qt5
	mkdir -p ${HOME}/.local/share/gdb/qt5
	git clone https://invent.kde.org/ebuka/gdb_printers.git ${HOME}/.local/share/gdb/qt5
	svn co svn://gcc.gnu.org/svn/gcc/trunk/libstdc++-v3/python ${HOME}/.local/share/gdb/stl
	stow --target=${TARGET_DIR} gdb

.PHONY: install-tmux
install-tmux: preinstall install-stow
	${SHELL} ${MKFILE_DIR}/script/tmux.sh
	stow --target=${TARGET_DIR} tmux

.PHONY: install-alacritty
install-alacritty: preinstall install-stow
	${SHELL} ${MKFILE_DIR}/script/alacritty.sh
	stow --target=${TARGET_DIR} alacritty

#.PHONY: install-i3
#install-i3: preinstall install-stow
#	${SHELL} ${MKFILE_DIR}/script/i3.sh
#	stow --target=${TARGET_DIR} i3 polybar rofi

.PHONY: install-lf
install-lf: preinstall install-stow
	${SHELL} ${MKFILE_DIR}/script/lf.sh
	stow --adopt --target=${TARGET_DIR} lf

.PHONY: install-fzf
install-fzf: preinstall
	${SHELL} ${MKFILE_DIR}/script/fzf.sh

.PHONY: install-fd
install-fd: preinstall
	${SHELL} ${MKFILE_DIR}/script/fd.sh

.PHONY: install-bat
install-bat: preinstall
	${SHELL} ${MKFILE_DIR}/script/bat.sh

.PHONY: install-rg
install-rg: preinstall
	${SHELL} ${MKFILE_DIR}/script/rg.sh

.PHONY: install-ninja
install-ninja: preinstall
	${SHELL} ${MKFILE_DIR}/script/ninja.sh

.PHONY: install-lazygit
install-lazygit: preinstall install-stow
	${SHELL} ${MKFILE_DIR}/script/lazygit.sh
	stow --target=${TARGET_DIR} lazygit

.PHONY: install-direnv
install-direnv: preinstall
	${SHELL} ${MKFILE_DIR}/script/direnv.sh

.PHONY: install-cmake
install-cmake: preinstall
	${SHELL} ${MKFILE_DIR}/script/cmake.sh

.PHONY: install-python
install-python: preinstall
	${SHELL} ${MKFILE_DIR}/script/python.sh

.PHONY: install-python-pip
install-python-pip: preinstall install-python
	${SHELL} ${MKFILE_DIR}/script/python_pip.sh

.PHONY: install-lsp-lua
install-lsp-lua: preinstall install-curl
	${SHELL} ${MKFILE_DIR}/script/lsp_lua.sh

.PHONY: install-lsp-cmake
install-lsp-cmake: preinstall install-yay
	${SHELL} ${MKFILE_DIR}/script/lsp_cmake.sh

.PHONY: install-lsp-python
install-lsp-python: preinstall install-yay
	${SHELL} ${MKFILE_DIR}/script/lsp_python.sh

.PHONY: install-lsp-bash
install-lsp-bash: preinstall
	${SHELL} ${MKFILE_DIR}/script/lsp_bash.sh

.PHONY: install-lld
install-lld: preinstall
	${SHELL} ${MKFILE_DIR}/script/lld.sh

.PHONY: install-lldb
install-lldb: preinstall
	${SHELL} ${MKFILE_DIR}/script/lldb.sh

.PHONY: install-curl
install-curl: preinstall
	${SHELL} ${MKFILE_DIR}/script/curl.sh

.PHONY: install-yay
install-yay: preinstall
	${SHELL} ${MKFILE_DIR}/script/yay.sh

.PHONY: clean
clean:
	stow --delete --target=${TARGET_DIR} fish nvim gdb tmux alacritty lf lazygit

.PHONY: preinstall
preinstall:
	${SHELL} ${MKFILE_DIR}/script/preinstall.sh
