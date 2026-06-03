#!/bin/bash

# Ensure the target directory exists so stow can create symlinks into it,
# then install the Claude Code CLI via the official install script.

mkdir -p "${HOME}/.claude"

echo ""
echo "================================================================"
echo "Installing Claude Code CLI via the official install script"
echo "Install instructions: https://docs.claude.com/en/docs/claude-code"
echo "================================================================"
echo ""

curl -fsSL https://claude.ai/install.sh | bash

exit $?
