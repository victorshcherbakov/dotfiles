#!/bin/bash

# Install a color emoji font so pictographic characters (U+1F300-U+1FAFF,
# U+2600-U+27BF, etc.) render as glyphs instead of tofu boxes in terminals
# that rely on fontconfig fallback (Alacritty, GNOME Terminal, xterm, etc.).
# OS validation is handled by preinstall.sh (Makefile dependency).

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed noto-fonts-emoji || exit $?
else
	sudo apt install fonts-noto-color-emoji || exit $?
fi

if [[ -x "$(command -v fc-cache)" ]]; then
	fc-cache -f
else
	>&2 echo "Warning: 'fc-cache' not found; the font is installed but the cache was not refreshed."
	>&2 echo "Install 'fontconfig' and run 'fc-cache -f' manually, or re-login to pick up the new font."
fi

exit 0
