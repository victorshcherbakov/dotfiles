---
name: open-commit-in-browser
description: Open a git commit in the GitLab web UI (any GitLab remote) in Chrome. Use when the user asks «открой коммит», «открой этот коммит в браузере», «покажи коммит в гитлабе», "open commit <hash>", or asks for a commit link. Opening a commit ALWAYS means the GitLab web page, never a local HTML dump.
---

# open-commit-in-browser

Opens one or more commits in the GitLab web UI in Google Chrome.

## Arguments

One or more commit refs (full/short hash, HEAD, branch~N). If no argument is
given, use the commit most recently discussed in the conversation; if there is
none, ask.

## Steps

1. Resolve each ref to a full hash: `git rev-parse <ref>`.
2. Derive the web base URL from the remote:
   `git remote get-url origin`, then normalize:
   - `ssh://git@host:port/group/repo` → `https://host/group/repo`
   - `git@host:group/repo.git` → `https://host/group/repo`
   - `https://host/group/repo.git` → strip `.git`
3. Commit URL: `<base>/-/commit/<full-hash>` (GitLab convention).
   When the user wants a SPECIFIC FILE inside the commit (e.g. reviewing one
   file's changes), deep-link to it — GitLab anchors each file in a diff by
   the SHA-1 of its repo-relative path:
   `<base>/-/commit/<full-hash>?file_path=<url-encoded path>#<sha1 of path>`
   where `<sha1 of path>` = `printf '%s' "<path>" | sha1sum` and
   `file_path` uses `%2F` for `/`. This opens the commit scrolled to the file
   with the file expanded.
4. Open in Chrome, detached:
   `google-chrome-stable <url> > /dev/null 2>&1 & disown`
   - Binary is `/usr/bin/google-chrome-stable` — do NOT use `xdg-open`,
     `google-chrome`, `chromium`, `firefox`.
5. Reply with the URL(s) so the user can copy them.

## Notes

- The user must see the real GitLab page (comments, pipelines, per-file view) —
  never substitute a locally generated diff dump unless GitLab is unreachable
  and the user agrees.
