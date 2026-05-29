# Global instructions for Claude Code

Rules in this file apply across all sessions and projects. Project-level
`CLAUDE.md` files extend / override per-project; this file holds preferences
that are universal to the user.

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
