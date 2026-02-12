#!/bin/bash
set -euo pipefail

# Always install/upgrade StyLua (Lua formatter) so Neovim tooling can call `stylua`.
# - On Arch/Manjaro: install/upgrade via pacman
# - On Debian/Ubuntu/Linux Mint: download latest GitHub release and overwrite ~/.local/bin/stylua

echo "[stylua] Starting install/upgrade..."

# Arch / Manjaro
if [[ -f /etc/arch-release ]]; then
  echo "[stylua] Detected Arch/Manjaro. Installing/upgrading via pacman..."
  # Update sync DB then install/upgrade stylua.
  # NOTE: `-Sy` updates package DB; if you prefer full upgrade, do it outside this script (`pacman -Syu`).
  sudo pacman -Sy --needed stylua
  echo "[stylua] Done."
  if command -v stylua >/dev/null 2>&1; then
    echo "[stylua] Using: $(command -v stylua)"
    stylua --version || true
  fi
  exit 0
fi

# Debian / Ubuntu / Linux Mint
echo "[stylua] Detected Debian/Ubuntu/Mint. Installing/upgrading from GitHub release..."

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Ensure deps: curl + jq + unzip
/bin/bash "${script_dir}/install_by_package_manager.sh" curl jq unzip

arch="$(uname -m)"
case "$arch" in
  x86_64) arch="x86_64" ;;
  aarch64|arm64) arch="aarch64" ;;
  *)
    >&2 echo "[stylua] Unsupported CPU architecture: ${arch}"
    exit 1
    ;;
esac

api_url="https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest"
echo "[stylua] Fetching: ${api_url}"

json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api_url}")"

# Prefer musl build (usually most portable across Ubuntu/Mint glibc versions)
asset_re="^stylua-linux-${arch}-musl\\.zip$"
url="$(
  echo "${json}" \
  | jq -r --arg re "${asset_re}" '.assets[] | select(.name | test($re)) | .browser_download_url' \
  | head -n 1
)"

if [[ -z "${url}" || "${url}" == "null" ]]; then
  >&2 echo "[stylua] Could not find an asset matching: ${asset_re}"
  >&2 echo "[stylua] Available assets:"
  echo "${json}" | jq -r '.assets[]?.name' || true
  exit 1
fi

local_bin="${HOME}/.local/bin"
mkdir -p "${local_bin}"

tmp_zip="$(mktemp -t stylua.XXXXXX.zip)"
tmp_dir="$(mktemp -d -t stylua.XXXXXX)"

echo "[stylua] Downloading: ${url}"
curl -fsSL "${url}" -o "${tmp_zip}"

echo "[stylua] Unpacking..."
unzip -q "${tmp_zip}" -d "${tmp_dir}"

bin_path="$(find "${tmp_dir}" -type f -name stylua -print -quit)"
if [[ -z "${bin_path}" ]]; then
  >&2 echo "[stylua] ERROR: 'stylua' binary not found in the archive"
  rm -rf "${tmp_dir}" "${tmp_zip}"
  exit 1
fi

echo "[stylua] Installing/upgrading -> ${local_bin}/stylua"
install -m 755 "${bin_path}" "${local_bin}/stylua"

rm -rf "${tmp_dir}" "${tmp_zip}"

echo "[stylua] Done."

# Show what will be used by shell
if command -v stylua >/dev/null 2>&1; then
  echo "[stylua] In PATH: $(command -v stylua)"
  stylua --version || true
else
  echo "[stylua] NOTE: stylua is installed into ${local_bin}, but not found in PATH."
  echo "[stylua] Add to PATH (bash/zsh): export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

