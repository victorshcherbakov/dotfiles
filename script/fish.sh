#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed fish
	exit $?
fi

echo "Fonts installation"
FONTS_DIR=${HOME}/.local/share/fonts/ttf/nerd-fonts/JetBrainsMono
sudo rm -r "${FONTS_DIR}"
mkdir -p "${FONTS_DIR}"
if [[ $? -ne 0 ]]; then
	exit $?
fi
svn co https://github.com/ryanoasis/nerd-fonts/trunk/patched-fonts/JetBrainsMono/Ligatures "${FONTS_DIR}"
if [[ $? -ne 0 ]]; then
	exit $?
fi
fc-cache -f
unset FONTS_DIR

echo "Add PPA for 'fish'"
sudo add-apt-repository -r ppa:fish-shell/release-3
if [[ $? -ne 0 ]]; then
	exit $?
fi
sudo add-apt-repository ppa:fish-shell/release-3
if [[ $? -ne 0 ]]; then
	exit $?
fi

echo "'fish' installation..."
sudo apt update
sudo apt install fish
if [[ $? -ne 0 ]]; then
	exit $?
fi

echo "Change your default shell"
TMPFILENAME=tmpfile_$(date +%s)
grep -v "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" $HOME/.bashrc > $TMPFILENAME && mv $TMPFILENAME $HOME/.bashrc
unset TMPFILENAME
echo "[ -x /usr/bin/fish ] && SHELL=/usr/bin/fish exec /usr/bin/fish" >> $HOME/.bashrc

echo "Theme installation from https://github.com/oh-my-fish/oh-my-fish"
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
fish --command="omf install bobthefish"
fish --command="omf theme bobthefish"

