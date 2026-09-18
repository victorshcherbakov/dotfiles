#!/bin/bash
set -euo pipefail

# Install/upgrade lua-language-server - the `lua_ls` server enabled in
# nvim/.config/nvim/lua/plugins/lspconfig.lua.
#
# The release tarball carries no top-level directory (bin/, main.lua, meta/ and
# script/ sit at its root), so it gets a payload directory of its own instead of
# being unpacked into ~/.local/bin among plain binaries. The server binary
# resolves that payload from its own real path, so a symlink into ~/.local/bin
# is enough to put it on PATH - verified by running it through one.

if [[ -f /etc/arch-release ]]; then
	sudo pacman -S --needed lua-language-server
	exit $?
fi

echo "[lsp-lua] Detected Debian/Ubuntu/Mint. Installing/upgrading from GitHub release..."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
/bin/bash "${script_dir}/install_by_package_manager.sh" curl jq tar

arch="$(uname -m)"
case "${arch}" in
	x86_64) asset_arch="x64" ;;
	aarch64 | arm64) asset_arch="arm64" ;;
	*)
		>&2 echo "[lsp-lua] Unsupported CPU architecture: ${arch}"
		exit 1
		;;
esac

api_url="https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"
echo "[lsp-lua] Requesting GitHub for the latest release from ${api_url}"
url="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api_url}" |
	jq -r --arg suffix "-linux-${asset_arch}.tar.gz" \
		'.assets[] | select(.name | endswith($suffix)) | .browser_download_url')"

if [[ -z "${url}" || "${url}" == "null" ]]; then
	>&2 echo "[lsp-lua] No linux-${asset_arch} tar.gz asset in the latest release"
	exit 1
fi

payload_dir="${HOME}/.local/share/lua-language-server"
link="${HOME}/.local/bin/lua-language-server"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

echo "[lsp-lua] Downloading: ${url}"
curl -fsSL "${url}" -o "${tmp_dir}/lls.tar.gz"

# Unpack next to the destination and swap only afterwards, so an interrupted
# download leaves the working installation alone.
mkdir -p "${tmp_dir}/payload"
tar -xzf "${tmp_dir}/lls.tar.gz" -C "${tmp_dir}/payload"

mkdir -p "$(dirname "${payload_dir}")" "$(dirname "${link}")"
rm -rf "${payload_dir}"
mv "${tmp_dir}/payload" "${payload_dir}"
echo "[lsp-lua] Installed -> ${payload_dir}"

if [[ -e "${link}" && ! -L "${link}" ]]; then
	>&2 echo "[lsp-lua] ${link} is a real file/directory, most likely an older"
	>&2 echo "[lsp-lua] hand-made installation. Move it aside and re-run to get the link."
else
	ln -sfn "${payload_dir}/bin/lua-language-server" "${link}"
	echo "[lsp-lua] ${link} -> ${payload_dir}/bin/lua-language-server"
fi

echo "[lsp-lua] Version: $("${payload_dir}/bin/lua-language-server" --version)"
