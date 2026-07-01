#!/bin/bash

# Arch doesn't regenerate the GRUB config when a kernel package is installed,
# upgraded, or removed, so an unbootable "wrong kernel version" mismatch can
# slip in after an update. This pacman hook runs grub-mkconfig right after any
# such transaction. pacman hooks don't exist on apt-based distros (Mint uses
# update-grub triggers of its own), so there's nothing to install there.
if [[ ! -f "/etc/arch-release" ]]; then
	echo "Not an Arch-based system; skipping the pacman grub-mkconfig hook."
	exit 0
fi

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
hook_src="${script_dir}/../pacman-hooks/99-grub-mkconfig.hook"
hook_dst="/etc/pacman.d/hooks/99-grub-mkconfig.hook"

# install -D creates /etc/pacman.d/hooks/ if it's missing; sudo makes the copy
# root-owned, which is what pacman expects for files under /etc.
sudo install -D -m 644 "${hook_src}" "${hook_dst}"

exit $?
