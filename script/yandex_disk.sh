#!/bin/bash

# Directories kept in the cloud only, never mirrored to local disk (photo/ alone
# is ~150 GB). yandex-disk reads exclude-dirs when the daemon starts: it stops
# syncing the dir but does NOT delete an already-downloaded local copy — after
# adding the option you must remove the local copy by hand once to reclaim space.
CONFIG="${HOME}/.config/yandex-disk/config.cfg"
EXCLUDE_DIRS="photo"

# Append exclude-dirs to an existing config, or tell the user how to add it if the
# config isn't created yet (it appears only after `yandex-disk setup`).
ensure_exclude_dirs() {
	if [ ! -f "${CONFIG}" ]; then
		echo "Config ${CONFIG} not found yet."
		echo "Run 'yandex-disk setup', then add this line to it: exclude-dirs=\"${EXCLUDE_DIRS}\""
		return
	fi
	if grep -q '^exclude-dirs=' "${CONFIG}"; then
		echo "exclude-dirs already set in ${CONFIG}"
	else
		echo "exclude-dirs=\"${EXCLUDE_DIRS}\"" >>"${CONFIG}"
		echo "Added exclude-dirs=\"${EXCLUDE_DIRS}\" to ${CONFIG}"
	fi
}

if [[ -f "/etc/arch-release" ]]; then
	echo "Enable AUR in 'pamac' and search for yandex-disk there"
	echo "After installation type 'yandex-disk setup'"
	ensure_exclude_dirs
	exit $?
fi

if [ ! -x "$(command -v wget)" ]; then
    echo "'wget' installation has been started."
    sudo apt update
    sudo apt install wget
else
    echo "Skip 'wget' installation"
fi

if [ ! -x "$(command -v yandex-disk)" ]; then
    echo "deb http://repo.yandex.ru/yandex-disk/deb/ stable main" | sudo tee -a /etc/apt/sources.list.d/yandex-disk.list > /dev/null && wget http://repo.yandex.ru/yandex-disk/YANDEX-DISK-KEY.GPG -O- | sudo apt-key add - && sudo apt-get update && sudo apt-get install -y yandex-disk
    yandex-disk setup
else
    echo "Skip 'yandex-disk' installation"
fi

ensure_exclude_dirs
