---
name: open-in-browser
description: Open a file or URL in Google Chrome. Use when the user asks «открой в браузере», «покажи в браузере», «открой это в Chrome», "open in browser", "show in browser" — for any local paths or URLs, or with no argument to open the document the session is currently working on. Call the Chrome binary directly; on Linux xdg-open sends .md/.html to a text editor instead.
---

# open-in-browser

Opens one or more files/URLs in Google Chrome, on Linux or on Windows.

## Arguments

One or more file paths and/or URLs separated by spaces.

With no arguments, open the document the session is currently working on, resolved
in this order — take the first rule that yields something:

1. The file this session most recently created or modified (Write, Edit, or a shell
   redirect/heredoc). Several candidates — the latest one.
2. Otherwise the last local path or URL the user named in the conversation.
3. Otherwise ask the user what to open and run nothing until they answer.

State which file was picked when confirming, so a wrong guess is visible at once.

## Command

Launch Chrome in the background so the session isn't blocked.

Linux:

    nohup google-chrome-stable <args> > /dev/null 2>&1 &

Windows (the Bash tool runs Git Bash):

    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" <args> > /dev/null 2>&1 &

## Rules

- Binary: `/usr/bin/google-chrome-stable` on Linux (Google's own package installs it
  under this name on every distro — Arch/Manjaro and Debian/Ubuntu alike); on
  Windows the path above, or `/c/Program Files/Google/Chrome/Application/chrome.exe`
  when the 32-bit one is absent — check with `ls` before launching. **Do not use**
  `google-chrome`, `chromium`, `xdg-open`, `firefox`: they are either not installed
  or don't open files in the browser.
- URLs are passed as-is on both systems.
- Local paths: as-is on Linux; on Windows convert first — `$(cygpath -w <path>)` —
  because Chrome does not understand a Git Bash `/c/...` path.
- If a path contains spaces, wrap it in double quotes inside the command.
- Don't wait for the process — Chrome stays running, the session continues. On Linux
  use `nohup ... &`, never `& disown`: the Bash tool's zsh runs without job control
  and `disown` fails with `no current job`, which kills the whole command line.
- After launching, briefly confirm to the user what was opened.
