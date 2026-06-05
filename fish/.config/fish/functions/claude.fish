function claude --wraps claude
    # Intercept `claude --resume/-r <session-id>` and warn if the session
    # belongs to another project directory: claude only searches the cwd's
    # project in ~/.claude/projects, so resuming from the wrong directory
    # fails with a misleading "No conversation found" error.
    set -l session_id ""
    for i in (seq (count $argv))
        if contains -- $argv[$i] --resume -r; and test (count $argv) -gt $i
            set session_id $argv[(math $i + 1)]
            break
        end
    end
    # only act on a real uuid (bare `--resume` opens the interactive picker)
    if string match -qr '^[0-9a-f-]{36}$' -- $session_id
        set -l transcript (find ~/.claude/projects -maxdepth 2 -name "$session_id.jsonl" 2>/dev/null | head -1)
        if test -z "$transcript"
            echo "Session $session_id not found in ~/.claude/projects"
            return 1
        end
        # every transcript line carries the session's launch directory
        set -l session_cwd (grep -m1 -o '"cwd":"[^"]*"' $transcript | cut -d'"' -f4)
        if test -n "$session_cwd"; and test "$session_cwd" != "$PWD"
            echo "Session $session_id is from another directory: $session_cwd"
            echo "Run: cd $session_cwd && claude $argv"
            return 1
        end
    end
    command claude $argv
end
