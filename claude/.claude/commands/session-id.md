Print the current Claude Code session id, determined reliably.
Do NOT use $CLAUDE_CODE_SESSION_ID — after `--fork-session` it reports the parent id.

How it works: write a unique marker into this session's transcript, then find which
transcript file contains it. That file's name (without .jsonl) is the session id.
Two steps are required — the marker must be flushed to the transcript (step 1) before
it can be searched (step 2).

Step 1 — emit a unique marker (run verbatim):

```bash
printf 'CCSID-%s-%s\n' "$RANDOM$RANDOM$RANDOM" "$$"
```

Step 2 — substitute <MARKER> with step 1's exact output, then run:

```bash
n=0; while [ "$n" -lt 20 ]; do
  hit=$(grep -l '<MARKER>' "$HOME"/.claude/projects/*/*.jsonl 2>/dev/null | head -1)
  [ -n "$hit" ] && { basename "$hit" .jsonl; break; }
  n=$((n + 1)); sleep 0.1
done
```

Reply with the id only, no extra commentary. Do not ask for confirmation.
