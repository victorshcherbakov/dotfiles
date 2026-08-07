---
name: pull-claude-md
description: Symlink the reference CLAUDE.md from ~/Yandex.Disk/Public/Settings/ into the current project root. Use when the user asks «скопируй claude.md из Settings», «обнови claude.md из настроек», «подтяни claude.md», «слинкуй claude.md», "pull claude.md", "link claude.md from settings".
---

# pull-claude-md

Links the reference `CLAUDE.md` kept on Yandex.Disk into the current project, so
the project always reads the live master copy — no re-pull needed after the
master is edited.

## Source and destination

- Source (link target): `/home/victor/Yandex.Disk/Public/Settings/CLAUDE.md`
- Destination (link): `CLAUDE.md` in the project root (the git repo root of the current session; fall back to the session's primary working directory if not a git repo).

## Steps

1. Inspect the destination with `ls -la` before touching it.
   - Already a symlink to the source (`readlink -f` matches) — nothing to do, say so.
   - Missing — create the link (step 2).
   - A regular file, or a symlink pointing elsewhere — `diff` it against the
     source and, if it differs, ask the user before replacing it: local rules
     living only in the project copy would be lost, and they should go to
     Settings first. Identical content needs no question.
2. Create the link with an absolute target: `ln -sfn <source> <destination>`
   (`-f` replaces an existing file or link, `-n` keeps it from being created
   *inside* a destination that is a symlink to a directory).
3. Confirm with `ls -la` output (shows `link -> target`) and both paths.

## Rules

- Never edit the source file in Settings from this skill; it is the master copy, updated separately.
- Do not commit anything. The link target is an absolute path under `/home/victor`,
  so it is machine-local — if the repo does not ignore `CLAUDE.md`, tell the user
  it shows up as untracked and should stay uncommitted.
