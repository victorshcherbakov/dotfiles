#!/bin/bash
set -euo pipefail

# Repair the apt source lists this machine accumulated. Four independent fixes:
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
#   4. Three repositories still verify against the shared /etc/apt/trusted.gpg,
#      which apt warns about: a key sitting there is accepted as a valid signer
#      for every repository on the machine. git-core is configured twice - a
#      stale list carrying a 2009 rsa1024 key from that keyring, and a current
#      one with a 4096-bit key of its own - so the stale list goes. yandex-disk
#      and deadsnakes get their key exported into /etc/apt/keyrings and a
#      signed-by option pointing at it.
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
YANDEX_KEY_FPR="EE2C95AB58DC2B0138D16B4FEFC4571D7C90E5AF"
DEADSNAKES_LIST="/etc/apt/sources.list.d/deadsnakes-ppa-jammy.list"
DEADSNAKES_KEY_FPR="F23C5A6CF475977595C89F51BA6932366A755776"
GIT_CORE_STALE_LIST="/etc/apt/sources.list.d/git-core-ppa-jammy.list"
GIT_CORE_LIST="/etc/apt/sources.list.d/git-core-ppa-noble.list"
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

# Move one repository off the shared legacy keyring: export its key into a file
# of its own and add signed-by to every uncommented deb line of its list.
migrate_key() {
	local name="$1" key_fpr="$2" list="$3"
	local keyring="/etc/apt/keyrings/${name}.gpg"

	if [[ ! -e "${list}" ]]; then
		say "${list} is not present, nothing to migrate"
		return 0
	fi
	if grep -q 'signed-by=' "${list}"; then
		say "${list} already points at a keyring of its own"
		return 0
	fi

	# --no-default-keyring keeps this from reading or writing the caller's own
	# keyrings; an empty result means the key is not where it was expected, and
	# rewriting the list then would leave the repository unverifiable.
	gpg --no-default-keyring --keyring /etc/apt/trusted.gpg \
		--export "${key_fpr}" >"${tmp_dir}/${name}.gpg" 2>/dev/null || true
	if [[ ! -s "${tmp_dir}/${name}.gpg" ]]; then
		>&2 echo "[apt-fix] ${key_fpr} is not in /etc/apt/trusted.gpg - leaving ${list} alone"
		return 0
	fi

	say "Giving ${list} its own keyring ${keyring}"
	if ((CHECK)); then
		say "would install ${keyring} with key ${key_fpr}"
	else
		sudo install -d -m 0755 /etc/apt/keyrings
		sudo install -m 0644 "${tmp_dir}/${name}.gpg" "${keyring}"
	fi

	backup "${list}"
	# Put signed-by inside the existing bracket when the line already carries
	# options, otherwise add a bracket right after the deb keyword.
	awk -v keyring="${keyring}" '
		/^[[:space:]]*#/ { print; next }
		$1 != "deb" && $1 != "deb-src" { print; next }
		/signed-by=/ { print; next }
		{
			if ($2 ~ /^\[/) { sub(/\]/, " signed-by=" keyring "]") }
			else { sub(/^[[:space:]]*deb(-src)?[[:space:]]+/, "&[signed-by=" keyring "] ") }
			print
		}
	' "${list}" | write_root "${list}"

	verify_lists+=("${list}")
	changed=1
}

changed=0
verify_lists=()

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
# --batch keeps gpg from asking anything, --yes lets it overwrite its own output.
gpg --batch --yes --dearmor -o "${tmp_dir}/google-chrome.gpg" "${tmp_dir}/google.pub"

# Compare before writing: an unchanged keyring must not be reinstalled, or every
# run would report work it did not do.
if cmp -s "${tmp_dir}/google-chrome.gpg" "${GOOGLE_KEYRING}" 2>/dev/null; then
	say "${GOOGLE_KEYRING} already holds this key"
elif ((CHECK)); then
	say "would install ${GOOGLE_KEYRING} from the downloaded key"
	changed=1
else
	sudo install -d -m 0755 /etc/apt/keyrings
	sudo install -m 0644 "${tmp_dir}/google-chrome.gpg" "${GOOGLE_KEYRING}"
	say "Installed ${GOOGLE_KEYRING}"
	changed=1
fi

verify_lists+=("${CHROME_LIST}")

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

##### 4. legacy trusted.gpg: give each repository a keyring of its own #########

if [[ -e "${GIT_CORE_STALE_LIST}" ]]; then
	if [[ -e "${GIT_CORE_LIST}" ]]; then
		say "Removing ${GIT_CORE_STALE_LIST} (same PPA and suite as ${GIT_CORE_LIST}, but on the legacy rsa1024 key)"
		backup "${GIT_CORE_STALE_LIST}"
		run sudo rm -f "${GIT_CORE_STALE_LIST}"
		changed=1
	else
		say "Keeping ${GIT_CORE_STALE_LIST}: ${GIT_CORE_LIST} is absent, dropping it would lose the PPA"
	fi
fi

migrate_key yandex-disk "${YANDEX_KEY_FPR}" "${YANDEX_LIST}"
migrate_key deadsnakes "${DEADSNAKES_KEY_FPR}" "${DEADSNAKES_LIST}"

##### Verify ##################################################################

if ((CHECK)); then
	say "Check mode: nothing was changed."
	exit 0
fi

((changed)) && say "Backups of every replaced file: ${BACKUP_DIR}"

# Refresh only the lists this run touched: sourcelist points at a single file
# and sourceparts at /dev/null so the rest of sources.list.d is not read, while
# List-Cleanup=no keeps apt from discarding the index files of the repositories
# it was told to ignore. A pass without warnings means the signature now
# verifies against the dedicated keyring.
for list in "${verify_lists[@]}"; do
	say "Refreshing ${list} to confirm its signature"
	if ! sudo apt-get update \
		-o Dir::Etc::sourcelist="${list}" \
		-o Dir::Etc::sourceparts=/dev/null \
		-o APT::Get::List-Cleanup=no; then
		>&2 echo "[apt-fix] ${list} does not verify. Restore it from ${BACKUP_DIR}${list} and report the error above."
		exit 1
	fi
done

say "Done. Run 'sudo apt-get update' for the full refresh."

# Left alone on purpose: the stale Google key also sits in the shared legacy
# /etc/apt/trusted.gpg. It is no longer consulted for this repo now that
# chrome.list carries signed-by, and editing that keyring risks the other
# repositories that still depend on it.
