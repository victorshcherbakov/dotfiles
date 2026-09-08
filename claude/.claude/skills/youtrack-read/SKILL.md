---
name: youtrack-read
description: Read an issue from the company YouTrack over its REST API - summary, description, custom fields, comments, attachments, links, change history. Use when the user names a ticket id or asks «посмотри тикет», «что в тикете», «прочитай задачу в YouTrack», «скачай вложение из тикета», "look at the ticket", "read the issue", "what does the ticket say". READ-ONLY - GET requests only, never comment, change fields or state, create or close issues.
---

# youtrack-read

Reads issues from the company YouTrack. The host lives outside this public
repo: the private import (`~/.claude/private.md`, section "YouTrack host")
names it. If that section is not loaded, ask the user for the host - never
guess it. `$HOST` below stands for that URL.

## Read-only

Only `GET`. Never POST/PUT/DELETE against the tracker: no comments, no
field/state/assignee changes, no creating, closing or uploading. The user's
access grant is read-only, and a write is an outward action the whole team
sees. When a task calls for a write, draft the text and hand it to the user to
paste.

## Token

- Auth is a permanent token: `Authorization: Bearer <token>`. Without it the
  API answers 401. The user creates one in YouTrack under Profile → Account
  Security → Authentication.
- Source, in order: a file the user names; `~/.config/youtrack-token` if it
  exists; otherwise ask - the user usually pastes the token into the chat for
  one task and revokes it afterwards.
- A pasted token goes into a scratchpad file with `chmod 600`. Pass agents the
  file path, never the value; never print it in a reply, a log or a commit.
- Tell the user as soon as the token has been used, so they can revoke it.

## Requests

Use `curl` from the Bash tool; WebFetch does not reach the host. Quote every
URL: an unquoted `?` makes zsh fail with `no matches found`.

Issue with the fields that usually matter:

```
curl -s -H "Authorization: Bearer $(cat <token-file>)" \
  "$HOST/api/issues/<ID>?fields=idReadable,summary,description,created,updated,reporter(fullName),customFields(name,value(name,fullName,text,presentation)),comments(author(fullName),created,text),attachments(name,url,size,mimeType),links(direction,linkType(name),issues(idReadable,summary))"
```

Change history: `$HOST/api/issues/<ID>/activities?categories=<Category,...>`;
category names and the `fields` to request are in the YouTrack REST docs.

Attachments: download with the same token via the `url` from the response. It
is relative to `$HOST` and already carries the `sign=` query.
