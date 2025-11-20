# ~/.config/fish/functions/fzf_rg.fish
function fzf_rg --description 'Fast, cancellable ripgrep + fzf content search'
    set -l seed (commandline -t)

    # ripgrep cmd (tweak to taste)
    set -l RG 'rg --hidden --smart-case --column --line-number --no-heading --color=always --max-columns 300 --glob "!.git/*"'

    # Choose a previewer
    if command -sq bat
        set -l PREVIEW 'bat --style=numbers --color=always --line-range :200 {1} --highlight-line {2}'
    else
        set -l PREVIEW 'sed -n "1,200p" {1}'
    end

    # fzf runs rg on demand; previous rg is killed automatically on change/abort
    set -l selected (fzf --ansi --disabled \
        --query "$seed" \
        --prompt='rg> ' \
        --delimiter : \
        --bind "change:reload:$RG {q} || true" \
        --bind "ctrl-c:abort,esc:abort" \
        --preview "$PREVIEW" \
        --preview-window='+{2}-/2,60%')

    test -n "$selected"; or return

    # selected line is "file:line:col:match..."
    set -l parts (string split -m 3 ':' -- $selected)
    set -l file $parts[1]
    set -l line $parts[2]

    # Open at the matching line in your $EDITOR
    set -l ed $EDITOR
    test -z "$ed"; and set ed nvim
    commandline -r "$ed +$line -- $file"
    commandline -f execute
end

