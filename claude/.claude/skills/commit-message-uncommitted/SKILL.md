---
name: commit-message-uncommitted
description: Write a commit message for the changes not yet committed — subject line ONLY, never a body. Use when the user asks «напиши сообщение для коммита», «сообщение для коммита», «текст коммита», «сообщение коммита», «напиши коммит», "write a commit message", "commit message for this". For already-committed work measured against the parent branch, use commit-message-branch instead.
---

# commit-message-uncommitted

Produce the commit **subject line and nothing else**, describing the work that is
not committed yet: the staged changes when anything is staged, the working tree
otherwise. Committed work measured against the parent branch belongs to
`commit-message-branch`.

## The rule

Output one line. No body, no bullet list, no "Why:", no trailing explanation. If
the message feels too small to carry the change, it is still one line — the user
reads the diff, not a retelling of it.

Write a body **only** when the user asks for one in that same request: «с описанием»,
«добавь описание», «нужно тело коммита», "with a description", "add a body". Absent
those words, a body is wrong even for large or multi-part changes.

## Writing the line

1. Look at what actually changed (`git diff --cached`, or `git diff` / `git status` when nothing is staged) — never write the message from memory of the conversation.
2. Take the format from master only: `git log --format=%s -20 master` (in a repo without `master`, its default branch). Never from HEAD, a feature branch or the commit being ported: those carry their author's habits. Read off the majority form of each part (verb and tense, the separator after the issue id, capitalization) and use it. This repo style beats the defaults in step 4.
3. An existing subject for the same issue (another branch, the commit being ported, the conversation) supplies the issue id and the facts, never the format. Do not reuse it verbatim.
4. Defaults where the log shows no pattern: imperative mood, no trailing period, under ~72 characters. Use an issue id only when the user or the work gives one; never invent one.
5. Name the change, not the file list: `Move public headers to include/` beats `Update CMakeLists and the install rules`.
6. Before printing, compare the line's prefix with the majority form on master character by character: verb, id, separator. Fix any mismatch.

## Scope

Asking for a message is not asking to commit. Print the line and stop — run
`git commit` only on a separate, explicit instruction.
