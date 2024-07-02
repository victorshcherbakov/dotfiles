#!/bin/bash

if [[ -f "/etc/arch-release" ]]; then
	sudo pacman -S --needed lua-language-server
	exit $?
fi

if ! [[ -x "$(command -v fish)" ]]; then
	>&2 echo "The fish isn't found. Install it before."
	>&2 echo "Error occured. Exit"
	exit 1
fi

# Install/update all the required packages
shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$shell "$script_dir/install_by_package_manager.sh" curl jq tar
if [[ $? -ne 0 ]]; then
	exit 1
fi

user=LuaLS
repo=lua-language-server
fname=-linux-x64.tar.gz
api_url="https://api.github.com/repos/${user}/${repo}/releases/latest"

# Fetch the download link for the latest release
echo "Requesting GitHub for the latest $repo release from $api_url"
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

local_bin="$HOME/.local/bin/lua-language-server"
mkdir -p "$local_bin"
if [[ $? -ne 0 ]]; then
	>&2 echo "Cannot create the directory \`$local_bin\`"
	>&2 echo "Error occured. Exit"
	exit 1
fi

tmp_fpath="/tmp/$user_$repo_$(date +%s)_$fname.tar.gz"
echo "URL: ${url}"
echo "Download binary"
curl --silent --location ${url} --output ${tmp_fpath}
if [[ $? -ne 0 ]]; then
	>&2 echo "Cannot download from \`$url\`"
	>&2 echo "Error occured. Exit"
	rm ${tmp_fpath}
	exit 1
fi

echo "Unpack .tar archive"
tar -xzf ${tmp_fpath} -C "$local_bin"

echo "Cleanup"
rm ${tmp_fpath}

lua_language_server_bin="$local_bin/bin"
if [ ! -d "$lua_language_server_bin" ] 
then
    echo "Directory \"$lua_language_server_bin\" DOES NOT exists." 
    exit 1
fi

fish --command="fish_add_path -a \"$lua_language_server_bin\""
exit 0
