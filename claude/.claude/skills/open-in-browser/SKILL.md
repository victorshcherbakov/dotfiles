---
name: open-in-browser
description: Open a file or URL in Google Chrome. Use when the user asks «открой в браузере», «покажи в браузере», «открой это в Chrome», "open in browser", "show in browser" — for any local paths or URLs. On this machine xdg-open opens .md/.html in a text editor, so always use google-chrome-stable directly.
---

# open-in-browser

Opens one or more files/URLs in Google Chrome on this machine.

## Arguments

One or more file paths and/or URLs separated by spaces. If no arguments are given, ask the user what to open and run nothing until they answer.

## Command

Launch Chrome in the background so the session isn't blocked:

    google-chrome-stable <args> > /dev/null 2>&1 & disown

## Rules

- Binary: `/usr/bin/google-chrome-stable`. **Do not use** `google-chrome`, `chromium`, `xdg-open`, `firefox` — on this machine they're either not installed or don't open files in the browser.
- Pass local paths as-is (Chrome handles `file://` itself); pass URLs as-is.
- If a path contains spaces, wrap it in double quotes inside the command.
- Don't wait for the process (`& disown`) — Chrome stays running, the session continues.
- After launching, briefly confirm to the user what was opened.
