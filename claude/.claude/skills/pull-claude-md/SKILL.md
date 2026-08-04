---
name: pull-claude-md
description: Copy the reference CLAUDE.md from ~/Yandex.Disk/Public/Settings/ into the current project root. Use when the user asks «скопируй claude.md из Settings», «обнови claude.md из настроек», «подтяни claude.md», "pull claude.md", "copy claude.md from settings".
---

# pull-claude-md

Copies the reference `CLAUDE.md` kept on Yandex.Disk into the current project.

## Source and destination

- Source: `/home/victor/Yandex.Disk/Public/Settings/CLAUDE.md`
- Destination: `CLAUDE.md` in the project root (the git repo root of the current session; fall back to the session's primary working directory if not a git repo).

## Steps

1. If the destination `CLAUDE.md` does not exist or is identical to the source — just copy (`cp`) and confirm.
2. If the destination exists and differs, show a short `diff` (source vs destination) and ask the user before overwriting — the project copy may contain newer local rules that should go to Settings first, not be lost.
3. After copying, confirm with both paths.

## Rules

- Never edit the source file in Settings from this skill; it is the master copy, updated separately.
- Do not commit anything.
