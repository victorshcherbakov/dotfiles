#!/bin/bash

# Check requirements
if [ ! -x "$(command -v git)" ]; then
    echo "'git' is required."
    exit 1
fi
if [ ! -x "$(command -v fc-cache)" ]; then
    echo "'fc-cache' is required."
    exit 1
fi
if [ ! -x "$(command -v curl)" ]; then
    echo "'curl' is required."
    exit 1
fi

echo "Fonts installation"
FONTS_DIR=${HOME}/.local/share/fonts/ttf/nerd-fonts/JetBrainsMono
RESTORE_PWD=`pwd`
sudo rm -r "${FONTS_DIR}"
mkdir -p "${FONTS_DIR}"
if [[ $? -ne 0 ]]; then
	exit $?
fi
git clone -n --depth=1 --filter=tree:0 https://github.com/ryanoasis/nerd-fonts "${FONTS_DIR}"
if [[ $? -ne 0 ]]; then
	exit $?
fi

cd "${FONTS_DIR}"
unset FONTS_DIR
git sparse-checkout set --no-cone patched-fonts/JetBrainsMono/Ligatures
if [[ $? -ne 0 ]]; then
	cd "${RESTORE_PWD}"
	exit $?
fi

git checkout
if [[ $? -ne 0 ]]; then
	cd "${RESTORE_PWD}"
	exit $?
fi

cd "${RESTORE_PWD}"
unset RESTORE_PWD

fc-cache -f

echo "'fish' installation..."

if [[ -f "/etc/arch-release" ]]; then
    sudo pacman -S --needed fish
else
    sudo apt install fish
fi

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

