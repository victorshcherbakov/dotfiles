#!/bin/bash
# Link the private parts of this configuration into the places that read them.
# They live in a directory on Yandex.Disk (synced across machines) instead of
# this repo, which is public.
#
# Fails loudly when anything is missing, and never deletes a real file to make
# room for a link. Silence would be the dangerous outcome: an absent blocklist
# leaves the pre-commit privacy scan matching generic patterns only, and an
# absent import drops global rules with no trace in the session.
#
# Override the source directory with PRIVATE_DOTFILES_DIR.
set -u

PRIVATE_DIR="${PRIVATE_DOTFILES_DIR:-${HOME}/Yandex.Disk/private/dotfiles}"

repo=$(cd "$(dirname "$0")/.." && pwd)
git_dir=$(git -C "${repo}" rev-parse --absolute-git-dir 2>/dev/null) || {
	echo "private: ${repo} is not a git repository" >&2
	exit 1
}

# "<path under PRIVATE_DIR>|<absolute destination>"; "-" means the file is read
# from PRIVATE_DIR directly and only has to exist.
entries=(
	"secret-patterns|${git_dir}/secret-patterns"
	"claude-private.md|${HOME}/.claude/private.md"
	"skills/customer-reply|${HOME}/.claude/skills/customer-reply"
	"ssh_config_private|-"
)

if [ ! -d "${PRIVATE_DIR}" ]; then
	echo "private: directory not found: ${PRIVATE_DIR}" >&2
	echo "private: is Yandex.Disk synced yet? PRIVATE_DOTFILES_DIR overrides the path" >&2
	exit 1
fi

failed=0
for entry in "${entries[@]}"; do
	src="${PRIVATE_DIR}/${entry%%|*}"
	dst="${entry##*|}"
	[ -e "${src}" ] || { echo "private: missing source ${src}" >&2; failed=1; continue; }
	[ "${dst}" = "-" ] && continue
	if [ -e "${dst}" ] && [ ! -L "${dst}" ]; then
		echo "private: ${dst} is a real file/directory - move it aside first" >&2
		failed=1
	fi
done
[ "${failed}" -eq 0 ] || exit 1

for entry in "${entries[@]}"; do
	src="${PRIVATE_DIR}/${entry%%|*}"
	dst="${entry##*|}"
	[ "${dst}" = "-" ] && continue
	mkdir -p "$(dirname "${dst}")"
	# -n so the link is not created *inside* a destination that already is a
	# symlink to a directory.
	ln -sfn "${src}" "${dst}"
	echo "private: ${dst} -> ${src}"
done
