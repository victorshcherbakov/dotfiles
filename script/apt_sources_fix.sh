#!/bin/bash
set -euo pipefail

# Repair the apt source lists this machine accumulated. Three independent fixes:
#
#   1. google-chrome: apt fails with NO_PUBKEY FD533C07C264648F. Google added
#      that signing subkey in 2025; the copies on disk stop at a 2024 subkey,
#      and the keyring the Chrome package normally ships
#      (/etc/apt/trusted.gpg.d/google-chrome.gpg) is gone - only its "~" backup
#      is left, which apt ignores. Fetch the current key into /etc/apt/keyrings
#      and point chrome.list at it with signed-by, so this repo no longer
#      depends on the shared legacy keyring.
#   2. openvpn3: the list asks for suite "stable", which returns 404 - that repo
#      publishes per Ubuntu codename, and has no build for this release. The
#      openvpn3 package is not installed, so the list only produces errors.
#   3. yandex-disk: the same "deb" line is present twice in one file, which is
#      where every "configured multiple times" warning comes from.
#
# Every file the script rewrites or removes is copied to a timestamped directory
# under /var/backups first - nothing is deleted outright. Re-running the script
# after a successful run changes nothing, so it is safe in a provisioning chain.
#
# Usage:
#   bash apt_sources_fix.sh            apply the fixes
#   bash apt_sources_fix.sh --check    print what would change, touch nothing

if [[ -f /etc/arch-release ]]; then
	echo "[apt-fix] Not an apt system, nothing to do."
	exit 0
fi

CHECK=0
case "${1:-}" in
	--check) CHECK=1 ;;
	"") ;;
	*)
		>&2 echo "Usage: ${0##*/} [--check]"
		exit 1
		;;
esac

# Google publishes one master key whose signing subkeys rotate; pinning the
# master fingerprint is what makes an unverified download safe to install.
GOOGLE_KEY_URL="https://dl.google.com/linux/linux_signing_key.pub"
GOOGLE_KEY_FPR="EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796"
GOOGLE_KEYRING="/etc/apt/keyrings/google-chrome.gpg"
GOOGLE_STALE_KEYRING="/etc/apt/trusted.gpg.d/google-chrome.gpg~"
CHROME_LIST="/etc/apt/sources.list.d/chrome.list"
OPENVPN3_LIST="/etc/apt/sources.list.d/openvpn3.list"
YANDEX_LIST="/etc/apt/sources.list.d/yandex-disk.list"
BACKUP_DIR="/var/backups/apt-sources-fix-$(date +%Y%m%d-%H%M%S)"

say() { printf '[apt-fix] %s\n' "$*"; }

run() {
	if ((CHECK)); then
		say "would run: $*"
	else
		"$@"
	fi
}

# Write stdin to a file only root may touch.
write_root() {
	local dest="$1"
	if ((CHECK)); then
		say "would write ${dest}:"
		sed 's/^/           /'
	else
		sudo tee "${dest}" >/dev/null
	fi
}

# Copy a file into the backup tree, keeping its full path, before it is changed.
backup() {
	local src="$1"
	[[ -e "${src}" ]] || return 0
	run sudo install -D -m 0644 "${src}" "${BACKUP_DIR}${src}"
}

changed=0

##### 1. google-chrome: install the current signing key, switch to signed-by ####

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

say "Fetching the Google signing key from ${GOOGLE_KEY_URL}"
curl -fsSL "${GOOGLE_KEY_URL}" -o "${tmp_dir}/google.pub"

# A captive portal or a proxy answers with HTML, and the split-tunnel setup on
# this machine makes that a real possibility - so parse the download and require
# the expected master key before anything reaches /etc/apt.
if ! gpg --show-keys --with-colons "${tmp_dir}/google.pub" 2>/dev/null |
	grep -q "^fpr:::::::::${GOOGLE_KEY_FPR}:"; then
	>&2 echo "[apt-fix] Downloaded key does not carry ${GOOGLE_KEY_FPR} - refusing to install it."
	exit 1
fi
say "Key verified: master fingerprint ${GOOGLE_KEY_FPR}"

# --dearmor converts the ASCII-armored key into the binary form apt expects.
if ((CHECK)); then
	say "would install ${GOOGLE_KEYRING} from the downloaded key"
	changed=1
else
	sudo install -d -m 0755 /etc/apt/keyrings
	sudo gpg --batch --yes --dearmor -o "${GOOGLE_KEYRING}" "${tmp_dir}/google.pub"
	sudo chmod 0644 "${GOOGLE_KEYRING}"
	say "Installed ${GOOGLE_KEYRING}"
	changed=1
fi

chrome_line="deb [arch=$(dpkg --print-architecture) signed-by=${GOOGLE_KEYRING}] http://dl.google.com/linux/chrome/deb/ stable main"
if [[ "$(cat "${CHROME_LIST}" 2>/dev/null || true)" != "${chrome_line}" ]]; then
	say "Rewriting ${CHROME_LIST} with signed-by"
	backup "${CHROME_LIST}"
	printf '%s\n' "${chrome_line}" | write_root "${CHROME_LIST}"
	changed=1
else
	say "${CHROME_LIST} already correct"
fi

# apt skips files ending in "~", so this one is dead weight that still looks
# like a keyring. Move it into the backup tree rather than deleting it.
if [[ -e "${GOOGLE_STALE_KEYRING}" ]]; then
	say "Moving the ignored backup keyring ${GOOGLE_STALE_KEYRING} out of /etc/apt"
	backup "${GOOGLE_STALE_KEYRING}"
	run sudo rm -f "${GOOGLE_STALE_KEYRING}"
	changed=1
fi

##### 2. openvpn3: drop the list that 404s ####################################

if [[ -e "${OPENVPN3_LIST}" ]]; then
	say "Removing ${OPENVPN3_LIST} (suite has no Release file; openvpn3 is not installed)"
	backup "${OPENVPN3_LIST}"
	run sudo rm -f "${OPENVPN3_LIST}"
	changed=1
else
	say "${OPENVPN3_LIST} already gone"
fi

##### 3. yandex-disk: collapse the duplicated entries #########################

if [[ -e "${YANDEX_LIST}" ]]; then
	# Drop a repeated entry, keep the first occurrence, and leave comments and
	# blank lines alone - two "#" lines in a row are not a duplicate repository.
	deduped="$(awk '!/^[[:space:]]*($|#)/ && seen[$0]++ { next } { print }' "${YANDEX_LIST}")"
	if [[ "${deduped}" != "$(cat "${YANDEX_LIST}")" ]]; then
		say "Collapsing duplicate entries in ${YANDEX_LIST}"
		backup "${YANDEX_LIST}"
		printf '%s\n' "${deduped}" | write_root "${YANDEX_LIST}"
		changed=1
	else
		say "${YANDEX_LIST} has no duplicates"
	fi
fi

##### Verify ##################################################################

if ((CHECK)); then
	say "Check mode: nothing was changed."
	exit 0
fi

((changed)) && say "Backups of every replaced file: ${BACKUP_DIR}"

# Refresh only the Chrome list: sourcelist points at that one file and
# sourceparts at /dev/null so the rest of sources.list.d is not read, while
# List-Cleanup=no keeps apt from discarding the index files of the repos it was
# told to ignore. A silent run here means the signature now verifies.
say "Refreshing the Chrome repository to confirm the signature"
sudo apt-get update \
	-o Dir::Etc::sourcelist="${CHROME_LIST}" \
	-o Dir::Etc::sourceparts=/dev/null \
	-o APT::Get::List-Cleanup=no

say "Done. Run 'sudo apt-get update' for the full refresh."

# Left alone on purpose: the stale Google key also sits in the shared legacy
# /etc/apt/trusted.gpg. It is no longer consulted for this repo now that
# chrome.list carries signed-by, and editing that keyring risks the other
# repositories that still depend on it.
