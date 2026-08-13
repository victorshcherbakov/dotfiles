#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ -f "/etc/arch-release" ]]; then
	# sublime-text-4 lives in the AUR; ensure the yay helper first.
	/bin/bash "${script_dir}/yay.sh" || exit $?
	yay -S --needed sublime-text-4
	exit $?
fi

# Linux Mint: Sublime ships only from the vendor's own apt repository, so
# register its key and source list once before the package can be installed.
keyring=/usr/share/keyrings/sublimehq-archive.gpg
repo_file=/etc/apt/sources.list.d/sublime-text.list

if [[ ! -f "${keyring}" ]]; then
	/bin/bash "${script_dir}/curl.sh" || exit $?
	curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg \
		| sudo gpg --dearmor -o "${keyring}" || exit $?
	sudo chmod 644 "${keyring}" || exit $?
fi

if [[ ! -f "${repo_file}" ]]; then
	echo "deb [signed-by=${keyring}] https://download.sublimetext.com/ apt/stable/" \
		| sudo tee "${repo_file}" > /dev/null || exit $?
fi

sudo apt update || exit $?

/bin/bash "${script_dir}/install_by_package_manager.sh" sublime-text
exit $?
