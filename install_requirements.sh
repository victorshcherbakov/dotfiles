#!/bin/bash

if [ ! -x "$(command -v make)" ]; then
    echo "'make' could not be found."
    exit
fi

if [ ! -x "$(command -v curl)" ]; then
    echo "'curl' installation has been started."
    sudo apt update
    sudo apt install curl
else
    echo "Skip 'curl' installation"
fi

if [ ! -x "$(command -v stow)" ]; then
    echo "'stow' installation has been started."
    sudo apt update
    sudo apt install stow
else
    echo "Skip 'stow' installation"
fi

if [ ! -x "$(command -v git)" ]; then
    echo "'git' installation has been started."
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update
    sudo apt install git
else
    echo "Skip 'git' installation"
fi

if [ ! -x "$(command -v svn)" ]; then
    echo "'svn' installation has been started."
    sudo apt update
    sudo apt install subversion
else
    echo "Skip 'svn' installation"
fi

if [ ! -x "$(command -v alacritty)" ]; then
    echo "'alacritty' installation has been started."
    sudo add-apt-repository ppa:aslatter/ppa
    sudo apt update
    sudo apt install alacritty
else
    echo "Skip 'alacritty' installation"
fi

FONTS_DIR=${HOME}/.local/share/fonts/ttf/nerd-fonts/JetBrainsMono
if [ ! -d "$FONTS_DIR" ]; then
    mkdir -p ${FONTS_DIR}
    svn co https://github.com/ryanoasis/nerd-fonts/trunk/patched-fonts/JetBrainsMono/Ligatures ${FONTS_DIR}
    fc-cache -f
else
    echo "Skip installation of fonts for alacritty"
fi
unset FONTS_DIR

if [ ! -x "$(command -v python3)" ]; then
    echo "'python3.9' installation has been started."
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install software-properties-common
    sudo apt install python3.9
    # sudo apt install python3-pip
else
    echo "Skip 'python3.9' installation"
fi

if [ ! -x "$(command -v cmake)" ]; then
    echo "To install 'cmake', go to https://cmake.org/download/"
    echo "and download the latest stable version."
    echo "Unpack it and add 'cmake/bin/' directory to the PATH. E.g.:"
    echo "fish_add_path $HOME/apps/cmake/bin/"
else
    echo "Skip 'cmake' installation"
fi

if [ ! -x "$(command -v fish)" ] && [ ! -d "$HOME/.config/fish" ]; then
    echo "'fish' installation has been started."

    echo "Add PPA for 'fish'"
    sudo add-apt-repository -r ppa:fish-shell/release-3
    sudo add-apt-repository ppa:fish-shell/release-3

    echo "'fish' installation..."
    sudo apt update
    sudo apt install fish

    echo "Change your default shell"
    TMPFILENAME=tmpfile_$(date +%s)
    grep -v "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" $HOME/.bashrc > $TMPFILENAME && mv $TMPFILENAME $HOME/.bashrc
    unset TMPFILENAME
    echo "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" >> $HOME/.bashrc

    echo "Adding config files to $HOME/.config/fish"
    make install-fish

    echo "Theme installation from https://github.com/oh-my-fish/oh-my-fish"
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    omf install bobthefish
    omf theme bobthefish
    exit
else
    echo "Skip 'fish' installation"
fi

