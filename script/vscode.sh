#!/usr/bin/env bash

echo "==> Visual Studio Code installer (Linux Mint / Ubuntu-based) and (Manjaro / Arch-based)"

if [[ -f "/etc/arch-release" ]]; then
	echo "TODO:"
	# exit $?
	exit 1
fi

set -e

echo "==> Visual Studio Code installer (Linux Mint / Ubuntu-based)"

KEYRING_PATH="/usr/share/keyrings/microsoft.gpg"
REPO_FILE="/etc/apt/sources.list.d/vscode.list"
FORCE=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --force)
      FORCE=true
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Usage: $0 [--force]"
      exit 1
      ;;
  esac
done

# Check if VS Code is already installed
if command -v code >/dev/null 2>&1 && [[ "$FORCE" = false ]]; then
  echo "==> VS Code is already installed, checking for updates"
fi

echo "==> Installing required dependencies"
sudo apt update || echo "Warning: apt update failed, continuing..."
sudo apt install -y wget gpg apt-transport-https

# Add Microsoft GPG key if it does not exist
if [[ -f "$KEYRING_PATH" ]]; then
  echo "==> Microsoft GPG key already exists"
else
  echo "==> Adding Microsoft GPG key"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | sudo gpg --dearmor -o "$KEYRING_PATH"
  sudo chmod 644 "$KEYRING_PATH"
fi

# Add VS Code repository if it does not exist
if [[ -f "$REPO_FILE" ]]; then
  echo "==> VS Code repository already exists"
else
  echo "==> Adding Visual Studio Code repository"
  echo "deb [arch=amd64 signed-by=$KEYRING_PATH] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee "$REPO_FILE" > /dev/null
fi

echo "==> Updating package index"
sudo apt update || echo "Warning: apt update failed, continuing..."

if [[ "$FORCE" = true ]]; then
  echo "==> Reinstalling Visual Studio Code (--force)"
  sudo apt install -y --reinstall code
else
  echo "==> Installing Visual Studio Code"
  sudo apt install -y code
fi

echo "==> Installation completed successfully"
echo "You can start VS Code by running: code"

