---
name: session-cleanup-list
description: List what the current session created that can now be cleaned up - verified against live state, short, numbered, cleanable items only. Use when the user asks «что можно почистить», «что почистить после сессии», «что ты создал за сессию», «список для очистки», «что осталось после работы», "what can be cleaned", "what did you create this session", "cleanup list", "what to clean up after this work", even when phrased as a question. Lists only; deleting anything needs a separate instruction.
---

# session-cleanup-list

Produce, in one reply, the list of things this session created that can now be removed. The first time this was asked it took five rounds: the list was too long, then it contained claims that were no longer true, then it had no numbers, then it mixed in things to keep. The first answer has to be the final one.

## 1. Collect candidates from the session's own actions

Walk through the tool calls of this conversation, not a recollection of them. Typical kinds:

- git: branches, worktrees, stashes and tags the session created; files it staged, or a tool it started staged (an editor's VCS plugin adds new assets on its own).
- Repository files: untracked files and directories the session created - test data, generated assets, recorded dumps.
- Build output: build trees and binaries the session built.
- Scratch: the session scratchpad, temp directories, patches, logs, scripts, config copies.
- Processes: editors, servers, virtual displays, buses the session started.

Skip what existed before the session (compare with the git status snapshot at session start, or with timestamps): it is not the session's to clean, even if the session touched it. Mention a pre-existing item only if the session changed it in a way the user may want to undo.

## 2. Verify every candidate against live state

State changes behind the session's back: the user pulls, pushes and deletes, another session works in the same repo. An item listed from memory can be stale - a commit rebased and pushed under another hash, a branch already gone, a process that already exited. So check each candidate with read-only commands before listing it: `git branch`, `git status`, `git branch -a --contains <sha>`, `git log --grep`, `ls`, `du -sh`, a process scan by exe or cmdline. Drop what no longer exists and describe the rest as it is now.

Asking for this list counts as asking for these read-only checks, even when the request is a question. Nothing is deleted here: removal needs a separate instruction that names the items.

## 3. Output

Only cleanable items - nothing to keep, nothing already removed, no history of what happened. A numbered list, one line per item: what it is, its absolute path or ref, its size when it takes disk space, and a few words on why removing it loses nothing. Mark items that are still useful `(optional)`. When an item could not be verified, write "not checked" on it instead of guessing. No preamble and no closing summary. If nothing can be cleaned, say so in one line.

Example:

1. Branch `feature-x` in `~/projects/repo2` - local only, its changes are in `3f1c2ab` on `origin/master`.
2. Debug build: `~/projects/repo2/build-debug` (4.0 GB) and the debug binaries in `bin/` - (optional) still useful for test runs.
3. Scratchpad `/tmp/claude-1001/<project>/<session>/scratchpad/` (8.1 MB) - logs, patches, test scripts.
