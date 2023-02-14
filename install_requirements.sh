#!/bin/bash

if [ ! -x "$(command -v stow)" ]; then
    echo "'stow' could not be found."
    exit
fi

if [ ! -x "$(command -v curl)" ]; then
    echo "'curl' could not be found."
    exit
fi

if [ ! -x "$(command -v make)" ]; then
    echo "'curl' could not be found."
    exit
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
    tmpfilename=tmpfile_$(date +%s)
    grep -v "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" $HOME/.bashrc > $tmpfilename && mv $tmpfilename $HOME/.bashrc
    unset tmpfilename
    echo "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" >> $HOME/.bashrc

    echo "Adding config files to $HOME/.config/fish"
    make install-fish

    echo "Theme installation from https://github.com/oh-my-fish/oh-my-fish"
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    omf install bobthefish
    omf theme bobthefish
    exit
else
    echo "Skip fish installation"
fi
