# Dotfiles

Персональные dotfiles, управляемые через [GNU Stow](https://www.gnu.org/software/stow/).

## Поддерживаемые ОС

- Arch Linux / Manjaro
- Linux Mint 22

## Установка

Полная установка всех инструментов:

```bash
make install
```

Установка отдельного инструмента:

```bash
make install-nvim
make install-tmux
make install-fish
make install-lsp-csharp
```

Удаление всех symlink'ов:

```bash
make clean
```

## Как это работает

Каждая директория верхнего уровня зеркалирует структуру домашней директории. GNU Stow создаёт symlink'и из репозитория в `$HOME`:

```
nvim/.config/nvim/  →  ~/.config/nvim/
tmux/.config/tmux/  →  ~/.config/tmux/
fish/.config/fish/  →  ~/.config/fish/
```

Скрипты установки в `script/` устанавливают сами программы через пакетный менеджер или GitHub Releases.

## Конфигурации

| Директория | Описание |
|------------|----------|
| `nvim/` | Neovim — Lazy.nvim, LSP, Telescope, Treesitter, blink.cmp |
| `tmux/` | Tmux — TPM, nord-tmux, tmux-resurrect |
| `fish/` | Fish shell — vi-mode, fzf, Oh-My-Fish |
| `alacritty/` | Alacritty — JetBrainsMono Nerd Font, tokyonight |
| `lazygit/` | Lazygit — кастомные команды |
| `lf/` | lf — файловый менеджер |
| `gdb/` | GDB — Qt5/STL printers, GDB Dashboard |

## Инструменты разработки

**LSP-серверы:** clangd, gopls, pyright, lua_ls, bashls, ts_ls, cmake, csharp_ls

**Утилиты:** ripgrep, fd, fzf, bat, ninja, cmake, mold, direnv

**Форматирование:** Stylua (Lua)

## Ключевые биндинги

- Neovim leader: `;`
- Tmux prefix: `Ctrl+A`
- Vi-style навигация во всех инструментах
