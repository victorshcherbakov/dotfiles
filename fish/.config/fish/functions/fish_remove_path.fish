# They don't want to add such a function.
# From https://github.com/fish-shell/fish-shell/issues/8604#issuecomment-1169638533
function fish_remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -e fish_user_paths[$index]
    echo "Removed `$argv` from the path"
    return
  end
    echo "Can't find `$argv` from the path"
end
