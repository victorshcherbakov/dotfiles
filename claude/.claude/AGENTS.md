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

## Presenting options in text

When you offer me choices in plain prose (not via the interactive question tool),
number them (1., 2., 3.) — never letter them (a/b/c). The interactive question tool
renders its own UI and is exempt.

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

## Shell environment (Bash tool runs zsh; login shell is fish)

The login/interactive shell is **fish** (`/usr/bin/fish`), but the Bash tool
executes commands via **zsh** (fish is not POSIX-compatible, so the tool does
not use it). Errors formatted `(eval):N: parse error near ...` come from zsh.

Write **bash/POSIX syntax** in tool commands — zsh accepts it. NEVER write
fish syntax (`set x ...`, `if ... end`, `and`/`or`) in tool commands; a zsh
parse error means a syntax slip in the command, not "should have been fish".

Two recurring traps — zsh defaults that differ from bash:

1. **Quote globs meant for the command.** zsh expands unquoted globs *before*
   passing them on and, unlike bash, aborts with `no matches found` when the cwd
   has no match. Quote them: `grep -rn --include='*.cpp'`, `find . -name '*.tsx'`.

2. **Variables do NOT word-split.** `FILES="a b c"; git add $FILES` passes a
   single argument → `pathspec did not match`. Pass paths inline or loop over an
   explicit list; don't rely on bash IFS splitting of unquoted variables.

(The same two behaviors apply in fish interactively, so the advice holds there
too.)

## Code conventions

After every Edit/Write of a C++ file (`.h`/`.cpp`/`.cxx`/`.cc`), run
`git clang-format` yourself on the changed lines of the files you just edited
(it formats only lines changed vs the index). Do this manually — it replaces the
old PostToolUse hook, which was removed because it also reformatted generated
files. Scope it to the files you edited; never run it over generated output
(e.g. codegen such as genapi `Gen*.cxx` / `Unigine*.h` facades) or over the whole
tree (no broad `/format` walk across `git diff`).

TODO / NOTE / FIXME / HACK marker format:
`KEYWORD(victor@unigine.com: DD/MM/YY): text`

e.g. `TODO(victor@unigine.com: 03/06/26): the message goes here`

Author is the email, date is `DD/MM/YY`. Same shape for NOTE / FIXME / HACK.

Comments explain *why* (non-obvious invariant, rationale, gotcha), never *what*
(the name and code already say that). A comment must stand alone for a reader of
this file — no dependence on the chat / PR / commit that produced it.

No provenance references in code. Phrases like "mirror of X", "like X does",
"as in X", "modeled on X" document where the pattern came from, not what the
reader needs here — that belongs in the commit message, not on the line.
Cross-reference another symbol only when the reader must actually go there (a
real coupling, a shared invariant, a gotcha). Deletion test: if removing the
comment / reference loses nothing the reader must act on, it was noise — drop it.
Prefer one line.

## Concurrent sessions share one working tree and index

A second Claude session may run in the same repo, in the same working tree,
against the same git index — there is one index per repo, so the other session's
`git add` stages into the index you also see. When another session has staged
WIP:

- `git add <your files>` + bare `git commit` commits the **entire** index — it
  sweeps the other session's staged files into your commit under your message.
  Commit only your paths: `git commit -- <explicit paths>` (a partial commit
  leaves the rest of the index staged and untouched).
- Before any commit, run `git diff --cached --name-only` and confirm only your
  files are listed.
- `git clang-format` with no pathspec reformats every staged file, corrupting
  the other session's files in the tree. Always scope it: `git clang-format -- <your paths>`.
- To undo a commit that swept up foreign WIP: `git reset --soft HEAD~1` (keeps
  the index; the working tree is never touched, so no content is lost), then
  re-commit only your paths via pathspec.
