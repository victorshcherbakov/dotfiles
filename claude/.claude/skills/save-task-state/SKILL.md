---
name: save-task-state
description: Gather the state of the current task from live sources, save it into the task's progress file and print a one-line restore prompt for a new session. Use when the user asks «собери и сохрани информацию по задаче», «сохрани состояние», «подготовь промпт для восстановления», «зафиксируй для нового чата», «чтобы восстановиться в новой сессии», "gather and save the task information", "prepare the restore prompt", "save state for a new session", "save the task state", or before the context runs out.
---

# save-task-state

Save everything a fresh session needs to continue this task, then print the restore prompt. The reader of the result has none of this conversation: what is not in the file is lost.

## 1. Find the progress file

Take the first that exists:

1. The progress file this task already uses (named in the conversation, in a memory entry, or in an earlier restore prompt).
2. The project's convention, e.g. `work/PROGRESS.md` (see the project's `CLAUDE.md`).
3. Otherwise ask the user where to keep it. Do not invent a location.

Read it before writing: update it in place, do not append a second copy of the same facts.

## 2. Gather from live state, not from memory

Run the commands; a hash or a count recalled from earlier in the session is often stale.

1. Git, for every repository and worktree the task touches: branch, `HEAD`, the upstream hash, the number and subjects of commits not pushed, uncommitted and untracked files, stashes made by this session.
2. What is done: each finished step with its commit hash.
3. What is in progress: the step, what is already changed on disk, what is left.
4. Decisions the user made in this session, with the date. Only explicit decisions: a question the user asked is not a decision.
5. Open questions waiting for the user, in the order to ask them.
6. Verification: what was built, tested and run, with the numbers seen, and what was NOT tested.
7. Traps met: the symptom and the fix, one line each.
8. How to build, test and run, if it took effort to find out.
9. Things that live outside the repository and will not survive: scratch files and scripts, background processes, test stands, edits on other machines. Either save what matters into the progress file or say it is lost.

## 3. Write the progress file

1. Sections, in this order, skipping empty ones: Goal, State (date, branch, hashes, pushed or not), Decisions, Next in order, How to build and test, Traps, Restore prompt.
2. Replace statements that are no longer true; a stale line is worse than a missing one.
3. Absolute dates. Every fact about code with its source (`file:line`, a command, a measurement); a guess is marked as a guess.
4. Do not copy what git already records (diffs, full commit messages); a hash and a few words are enough.
5. Follow the user's document rules (language of the file, no hard-wrapped prose, numbered lists, links for tickets and commits where they render).

## 4. Restore prompt

One line, self-contained, copy-pastable, starting with `Restore:`. It carries, in this order:

1. The task in a few words.
2. What to read first: the absolute path of the progress file, then other notes.
3. Where the work is: repository or worktree, branch, `HEAD` hash, pushed or not.
4. Standing rules of this task the new session must not rediscover (how to build, what never to do, how the user wants to be asked).
5. The immediate next step, then the ones after it.

Put the same line into the Restore prompt section of the progress file and into the reply. The two must be identical.

## 5. Keep the pointers in step

If a memory entry or an index line points at this task, update its one-line state (hashes, pushed or not, next step) so it does not contradict the file.

## 6. Check and report

1. Re-read the hashes in the file against `git rev-parse`; fix any mismatch.
2. Reply with: the path of the progress file, what was added or corrected in a few lines, anything that could not be saved, and the restore prompt on its own line.

Do not commit or push the progress file unless the user asks.
