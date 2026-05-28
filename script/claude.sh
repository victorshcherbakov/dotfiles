#!/bin/bash

# Claude Code itself is installed separately (npm). This script only ensures
# the target directory exists so stow can create symlinks into it, and prints
# a reminder about installing the CLI.

mkdir -p "${HOME}/.claude"

echo ""
echo "================================================================"
echo "Claude Code is an external tool that must be installed separately"
echo "Install instructions: https://docs.claude.com/en/docs/claude-code"
echo "Quick install (npm):  npm install -g @anthropic-ai/claude-code"
echo "================================================================"
echo ""

exit 0
