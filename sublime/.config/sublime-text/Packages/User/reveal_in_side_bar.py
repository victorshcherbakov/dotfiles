"""Keep the side bar tree expanded on whatever file is currently focused.

Sublime only reveals a file on demand (Context menu -> Reveal in Side Bar);
there is no built-in setting for doing it on every buffer switch.
"""

import sublime_plugin


class RevealActiveFileInSideBar(sublime_plugin.EventListener):
    def on_activated_async(self, view):
        # Widgets (find panel, console, quick panel input) carry no path, and
        # revealing them would only clear the current side bar selection.
        if view.settings().get("is_widget") or not view.file_name():
            return

        window = view.window()
        if window is None:
            return

        # The command un-hides a side bar the user deliberately closed, so only
        # reveal when the tree is already on screen.
        if window.is_sidebar_visible():
            window.run_command("reveal_in_side_bar")
