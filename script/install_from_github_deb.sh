#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "Please use this script like:"
	echo "${0##*/} {github_user_name} {github_user_repository_name} {trailing_part_of_archive_name}"
	echo "${0##*/} neovim neovim nvim-linux64.deb"
	exit 1
fi

# Install/update all the required packages
shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$shell "$script_dir/install_by_package_manager.sh" curl jq
if [[ $? -ne 0 ]]; then
	exit 1
fi

user=$1
repo=$2
fname=$3
api_url="https://api.github.com/repos/${user}/${repo}/releases/latest"


# Fetch the download link for the latest release
echo "Requesting GitHub for the latest $repo release"
http_resp=$(curl -L -s -H 'Accept: application/json' ${api_url})
if [[ $? -ne 0 ]]; then
	>&2 echo "Error occured ($?). Exit"
	exit 1
fi

url=$(echo ${http_resp} | jq '.assets[]
	| {name: .name, url: .browser_download_url}
	| select(.name | test(".*'${fname}'"))
	| .url' \
	| tr -d '"')

if [[ -z ${url} ]]; then
	>&2 echo "Download URL not found"
	>&2 echo "Error occured. Exit"
	exit 1
fi

echo "URL: ${url}"
echo "Download binary"
tmp_fpath="/tmp/$(date +%s)_${fname}"
curl --silent --location ${url} --output ${tmp_fpath}

echo "Install .deb package"
sudo dpkg -i ${tmp_fpath}

echo "Cleanup"
rm ${tmp_fpath}