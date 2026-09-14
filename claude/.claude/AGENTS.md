# Global instructions for Claude Code

Rules in this file apply across all sessions and projects. Project-level
`CLAUDE.md` files extend / override per-project; this file holds preferences
that are universal to the user.

Rules that name an employer, an internal host or a private tool live outside
this public repo, on Yandex.Disk, and arrive through the import below. It is a
symlink created by `make install-private`; when it is missing the import simply
resolves to nothing, so anything that depends on it says so explicitly here.

@~/.claude/private.md

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

## Ticket references in documents

Every tracker ticket id written into a document (`PROJ-1234`, i.e. a project
prefix, a dash, a number) is a markdown link to the ticket, never bare text:
`[PROJ-1234](<tracker>/issue/PROJ-1234)`. Every occurrence, not only the first
one - the reader clicks wherever they are in the page. The tracker URL and the
real project prefixes are employer data, so they live in the private import
("YouTrack host" section); without that section, ask for the host rather than
guessing it. Plain text stays plain where a link cannot render: commit messages,
code comments, shell output.

## No unsourced claims

Every statement about how someone else's code, API, or system behaves needs a
named source — `file:line`, documentation, command output, or an experiment you
ran. No source means either saying "assumption, not verified" or going and
checking. This bites hardest on causal claims: "the pointer isn't ours",
"otherwise it double-frees", "on failure the function leaves X untouched".

Never justify code with an unverified guess. Check first — grep the vendored
headers, read the docs, temporarily patch a branch and run it — then write the
lines. Call an unexercised code path unexercised instead of describing its
behavior with confidence, and keep "fact (source)" and "guess (unverified)"
visibly apart when reporting.

## Measure instead of guessing

Adding diagnostic logging to find out why something happens is a correct, expected
move, not a last resort. When the cause is not visible from reading the code in a
pass or two, do not narrow the answer to "probably" or "it depends" — put prints
at the branch points, reproduce, and read the output. One measurement beats five
speculative edits.

The same goes for a minimal standalone reproduction outside the project when the
question is really about a compiler, a library, or an OS API: a twenty-line file
built with the project's own flags answers it in seconds, and the answer is a
fact rather than a recollection.

Remove the instrumentation once the cause is found and written down.

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

## Shell environment (Bash tool runs bash; login shell is fish)

The login shell is **fish** and is not POSIX-compatible, so Claude Code does not
use it for the Bash tool. `SHELL=/bin/bash` in `~/.claude/settings.json` pins
the tool to **bash**; without that pin Claude Code falls back to zsh, whose
stricter globbing turns valid bash one-liners into hard errors — an unmatched
glob, a `--include=*.cpp`, an `echo === banner ===` or a `$REV:path` aborts the
command instead of running it.

Write bash/POSIX syntax. NEVER fish syntax (`set x ...`, `if ... end`,
`and`/`or`) in tool commands. An error reading `(eval):N: ...` or `zsh: ...`
means the pin is not in effect on this machine: say so instead of guessing at
the syntax, and re-check `settings.json`.

Three traps that are not the shell's fault and survive the switch:

1. **`--` goes after every flag, never before it.** `grep -- "$pat" -r .` makes
   `-r` a filename and silently finds nothing; `git commit -- <paths> -m "msg"`
   makes `-m` a pathspec.
2. **The cwd resets to the project root before every Bash call.** A `cd` lasts
   only inside its own command, and later relative paths resolve against that
   new directory — `cd build && ... && git commit -- source/x.cpp` fails with
   `pathspec did not match`. Prefer absolute paths and `git -C <repo>`.
3. **Prefix a glob that feeds a command with `./`.** A match starting with `-`
   becomes an option: `ls -d */` breaks in a directory holding `-foo/`.

## Code conventions

Before any `git commit` that includes C++ files (`.h`/`.cpp`/`.cxx`/`.cc`),
run `git clang-format -- <files you edited>` (formats only changed lines),
re-stage those files, then commit. Do NOT format after every Edit/Write —
only at commit time. Do this manually — it replaces the old PostToolUse hook,
which was removed because it also reformatted generated files. Scope it to
the files you edited; never run it over generated output (the private import
names the codegen file patterns) or over the whole tree (no broad `/format` walk
across `git diff`).

TODO / NOTE / FIXME / HACK marker format:
`KEYWORD(<author-email>: DD/MM/YY): text`

e.g. `TODO(<author-email>: 03/06/26): the message goes here`

Date is `DD/MM/YY`; the author email comes from the private import — ask if it
did not load. Same shape for NOTE / FIXME / HACK.

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
