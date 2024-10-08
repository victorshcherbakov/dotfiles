#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	echo "Enable AUR in 'pamac' and search for yandex-disk there"
	echo "After installation type 'yandex-disk setup'"
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

