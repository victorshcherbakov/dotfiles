#!/bin/bash

if [[ $# -lt 3 || $# -gt 4 ]]; then
	echo "Please use this script in this way:"
	echo "${0##*/} {github_user_name} {github_user_repository_name} {trailing_part_of_archive_name} [binary_name_for_gz]"
	echo "${0##*/} junegunn fzf -linux_amd64.tar.gz"
	echo "${0##*/} tree-sitter tree-sitter -linux-x64.gz tree-sitter"
	exit 1
fi

user=$1
repo=$2
fname=$3
# Optional 4th arg: name of the resulting binary when the asset is a raw .gz
# (single gzipped binary, not a tarball). Defaults to repo name.
binary_name=${4:-$repo}

# Detect archive format from the asset suffix
case "$fname" in
	*.tar.gz|*.tgz) fmt="tar.gz" ;;
	*.zip) fmt="zip" ;;
	*.gz) fmt="gz" ;;
	*)
		>&2 echo "Unsupported archive format for asset: ${fname}"
		>&2 echo "Supported: .tar.gz, .tgz, .zip, .gz"
		exit 1
		;;
esac

# Install/update all the required packages, format-specific
shell=/bin/bash
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
deps=(curl jq)
case "$fmt" in
	tar.gz) deps+=(tar) ;;
	zip)    deps+=(unzip) ;;
	gz)     deps+=(gzip) ;;
esac
$shell "$script_dir/install_by_package_manager.sh" "${deps[@]}"
if [[ $? -ne 0 ]]; then
	exit 1
fi

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
	>&2 echo "Download URL not found, url: ${url}, fname: ${fname}"
	>&2 echo "Error occured. Exit"
	exit 1
fi

local_dir="${HOME}/.local/bin"
mkdir -p "${local_dir}"
if [[ $? -ne 0 ]]; then
	>&2 echo "Cannot create the directory \`${local_dir}\`"
	>&2 echo "Error occured. Exit"
	exit 1
fi

tmp_fpath="/tmp/$user_$repo_$(date +%s)_$fname.${fmt}"
echo "URL: ${url}"
echo "Download binary from: ${url}"
curl --silent --location ${url} --output ${tmp_fpath}
if [[ $? -ne 0 ]]; then
	>&2 echo "Cannot download from \`$url\`"
	>&2 echo "Error occured. Exit"
	rm ${tmp_fpath}
	exit 1
fi

case "$fmt" in
	tar.gz)
		echo "Unpack .tar.gz archive to: ${local_dir}"
		tar -xzf ${tmp_fpath} -C "${local_dir}"
		;;
	zip)
		echo "Unpack .zip archive to: ${local_dir}"
		unzip -o ${tmp_fpath} -d "${local_dir}"
		;;
	gz)
		echo "Unpack .gz binary to: ${local_dir}/${binary_name}"
		# Single gzipped binary — decompress to stdout and write under repo name.
		gunzip -c ${tmp_fpath} > "${local_dir}/${binary_name}"
		chmod +x "${local_dir}/${binary_name}"
		;;
esac

echo "Cleanup"
rm ${tmp_fpath}
