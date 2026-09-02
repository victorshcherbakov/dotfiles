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

1. Look at what actually changed (`git diff --cached`, or `git diff` / `git status`
   when nothing is staged) — never write the message from memory of the conversation.
2. Match the style of the repository: `git log --oneline -10`. Some repos prefix an
   issue id (`AB-1234: ...`); reuse that shape when the user gave an id, and never
   invent one.
3. Imperative mood, no trailing period, ideally under ~72 characters.
4. Name the change, not the file list: `Move public headers to include/`
   beats `Update CMakeLists and the install rules`.

## Scope

Asking for a message is not asking to commit. Print the line and stop — run
`git commit` only on a separate, explicit instruction.
