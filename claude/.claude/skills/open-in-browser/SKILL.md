---
name: open-in-browser
description: Open a file or URL in Google Chrome. Use when the user asks «открой в браузере», «покажи в браузере», «открой это в Chrome», "open in browser", "show in browser" — for any local paths or URLs. Call the Chrome binary directly; on Linux xdg-open sends .md/.html to a text editor instead.
---

# open-in-browser

Opens one or more files/URLs in Google Chrome, on Linux or on Windows.

## Arguments

One or more file paths and/or URLs separated by spaces. If no arguments are given, ask the user what to open and run nothing until they answer.

## Command

Launch Chrome in the background so the session isn't blocked.

Linux:

    google-chrome-stable <args> > /dev/null 2>&1 & disown

Windows (the Bash tool runs Git Bash):

    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" <args> > /dev/null 2>&1 &

## Rules

- Binary: `/usr/bin/google-chrome-stable` on Linux; on Windows the path above, or
  `/c/Program Files/Google/Chrome/Application/chrome.exe` when the 32-bit one is
  absent — check with `ls` before launching. **Do not use** `google-chrome`,
  `chromium`, `xdg-open`, `firefox`: they are either not installed or don't open
  files in the browser.
- URLs are passed as-is on both systems.
- Local paths: as-is on Linux; on Windows convert first — `$(cygpath -w <path>)` —
  because Chrome does not understand a Git Bash `/c/...` path.
- If a path contains spaces, wrap it in double quotes inside the command.
- Don't wait for the process (`& disown`, or a bare `&` on Windows) — Chrome stays
  running, the session continues.
- After launching, briefly confirm to the user what was opened.
