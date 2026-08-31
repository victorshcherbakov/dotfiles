#!/usr/bin/env python3
"""Desktop notification shared by the hooks, on Linux and on Windows.

Linux gets notify-send (plus a sound for urgent messages); Windows gets a toast
raised through PowerShell's WinRT bindings, with the text passed in environment
variables so no message content is ever re-parsed by a shell. Every failure is
swallowed - a hook must not break the session over a notification that did not
reach the desktop.
"""
from __future__ import annotations

import os
import subprocess

LINUX_SOUND = "/usr/share/sounds/freedesktop/stereo/dialog-warning.oga"

# A toast needs an AppUserModelID owning a Start-menu shortcut; PowerShell's own
# is the one shortcut every Windows install is guaranteed to have.
WINDOWS_APP_ID = r"{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"

WINDOWS_TOAST = """
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
    [Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$text = $template.GetElementsByTagName('text')
$text.Item(0).AppendChild($template.CreateTextNode($env:CLAUDE_NOTIFY_TITLE)) | Out-Null
$text.Item(1).AppendChild($template.CreateTextNode($env:CLAUDE_NOTIFY_BODY)) | Out-Null
$toast = [Windows.UI.Notifications.ToastNotification]::new($template)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(
    $env:CLAUDE_NOTIFY_APP_ID).Show($toast)
"""

# Keeps a console window from flashing when a hook spawns PowerShell; the flag
# only exists on Windows.
NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0)


def notify(title: str, body: str, urgent: bool = False) -> None:
    """Show a desktop notification, or do nothing if the desktop won't take it."""
    if os.name == "nt":
        _notify_windows(title, body)
    else:
        _notify_linux(title, body, urgent)


def _notify_windows(title: str, body: str) -> None:
    env = dict(os.environ)
    env["CLAUDE_NOTIFY_TITLE"] = title
    env["CLAUDE_NOTIFY_BODY"] = body
    env["CLAUDE_NOTIFY_APP_ID"] = WINDOWS_APP_ID
    try:
        subprocess.Popen(
            ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", WINDOWS_TOAST],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=NO_WINDOW,
        )
    except OSError:
        pass


def _notify_linux(title: str, body: str, urgent: bool) -> None:
    urgency = "critical" if urgent else "normal"
    try:
        subprocess.Popen(
            ["notify-send", "-u", urgency, "-a", "Claude Code",
             "-i", "dialog-information", title, body],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except OSError:
        return
    if urgent and os.path.isfile(LINUX_SOUND):
        try:
            subprocess.Popen(
                ["paplay", LINUX_SOUND],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            pass
