# Global instructions for Claude Code

Rules in this file apply across all sessions and projects. Project-level
`CLAUDE.md` files extend / override per-project; this file holds preferences
that are universal to the user.

## Config file language

Everything under the dotfiles `claude/` package — skills, commands, hooks,
and this file — is written in concise English to keep token cost low. The
sole exception is Russian user-command trigger phrases (e.g. the «открой в
браузере» list in `open-in-browser/SKILL.md`), which stay in Russian so the
phrasing still matches when the user speaks Russian.

## Session restore one-liner

When the user asks to save the current state so they can resume in a new
session (triggers: «сохрани состояние», «чтобы восстановиться в новой
сессии», «зафиксируй для нового чата», "save state for new session", etc.),
besides updating the project's `PROGRESS.md` (or equivalent), **also output
a copy-pastable one-line restore comment** in the same response.

The one-liner must be self-contained: where to read (progress / plan files),
current stage, immediate next step. Keep it on a single (possibly long) line —
no bullet lists or multi-line blocks. If `PROGRESS.md` has a restore-prompt
section, keep the one-liner in sync with it.

Reason: the user wants a fast, copyable way to resume a task in a fresh chat
without recalling context by hand.

## Shell environment (fish)

The interactive shell is **fish** (`/usr/bin/fish`), not bash. Two recurring
Bash-command traps:

1. **Quote globs meant for the command.** Fish expands unquoted globs *before*
   passing them on and, unlike bash, aborts with `no matches found` when the cwd
   has no match. Quote them: `grep -rn --include='*.cpp'`, `find . -name '*.tsx'`.

2. **Variables do NOT word-split.** `set FILES "a b c"; git add $FILES` passes a
   single argument → `pathspec did not match`. Pass paths inline, or use a real
   fish list (`set FILES a b c` — each path its own token); never a quoted,
   space-joined variable, and don't rely on bash IFS splitting.

## Code conventions

TODO / NOTE / FIXME / HACK marker format:
`KEYWORD(victor@unigine.com: DD/MM/YY): text`

e.g. `TODO(victor@unigine.com: 03/06/26): the message goes here`

Author is the email, date is `DD/MM/YY`. Same shape for NOTE / FIXME / HACK.
