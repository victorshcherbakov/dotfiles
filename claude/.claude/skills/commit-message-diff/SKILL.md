---
name: commit-message-diff
description: Write a commit message for the work already committed on this branch, measured against its parent branch — subject line ONLY, never a body. Use when the user asks «сообщение для изменений в ветке», «коммит-месседж для ветки», «сообщение относительно родительской ветки», «текст для squash», "commit message for the branch", "message for the branch diff", "squash message". For uncommitted changes use commit-message-head instead.
---

# commit-message-diff

Produce the commit **subject line and nothing else**, describing what this branch
changed relative to its parent branch. Typical use: the subject for a squash, a
merge request title, or a summary of the branch.

Style rules are shared with the sibling skill: read
`~/.claude/skills/commit-message-head/SKILL.md` and follow its "The rule" and
"Writing the line" sections. Only the target selection below differs.

## Finding the parent branch

Use the branch the user names. Otherwise pick the release or default branch whose
fork point is closest to HEAD:

```bash
git for-each-ref --format='%(refname:short)' \
    refs/remotes/origin/master refs/remotes/origin/main 'refs/remotes/origin/ver-*' |
  while read -r ref; do
    base=$(git merge-base "$ref" HEAD) || continue
    printf '%s %s\n' "$(git log -1 --format=%ct "$base")" "$ref"
  done | sort -rn | head -1
```

Name the parent you settled on in the reply, so a wrong guess is visible.

## Reading the changes

```bash
git diff <parent>...HEAD --stat      # three dots: fork point..HEAD
git log --oneline <parent>..HEAD --no-merges
```

Three dots matter: they exclude everything the branch merged in from the parent,
leaving only its own work.

The diff, not the log, is the source of truth. A commit can be listed by `git log`
while contributing nothing to the diff — its content reached the parent branch
under a different SHA (cherry-pick, rework upstream). Describe the diff; mention
such commits only to explain why they are absent from it.

An empty diff means the branch adds nothing on top of its parent. Say exactly
that instead of writing a message for the commits in the log.
