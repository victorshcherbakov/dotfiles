Run clang-format on changed lines of all modified C++ files.

Execute this bash command:

```bash
cd "$(git rev-parse --show-toplevel)"
CLANG_FORMAT=$(command -v clang-format || echo "/c/Program Files/LLVM/bin/clang-format.exe")
git diff -U0 --diff-filter=d --name-only | grep -E '\.(cpp|cc|cxx|c|h|hpp|hxx)$' | while IFS= read -r file; do
  args=()
  while IFS=, read -r start count; do
    [ -z "$count" ] && count=1
    [ "$count" = 0 ] && count=1
    args+=("--lines=$start:$((start + count - 1))")
  done < <(git diff -U0 -- "$file" | grep -oP '^@@ -[0-9]+(,[0-9]+)? \+\K[0-9]+(,[0-9]+)?')
  if [ ${#args[@]} -gt 0 ]; then
    "$CLANG_FORMAT" "${args[@]}" -i "$file"
    echo "Formatted: $file"
  fi
done
echo "Done."
```

Do not ask for confirmation — just run it.

Why this form (shell here is zsh, not bash):
- Hunk parsing uses `grep -oP '... \+\K...'`, not `awk '... match($0, ...)'`. In a slash-command body `$0`/`$1`/… are substituted as command arguments, so the old `$0` was eaten and awk broke.
- Ranges are collected into an array expanded as `"${args[@]}"`: in zsh an unquoted string does not word-split, so multiple `--lines=` flags would otherwise collapse into one argument.
- `< <(...)` feeds the inner loop in the current shell so the array accumulates (a piped `while` runs in a subshell and loses it).
