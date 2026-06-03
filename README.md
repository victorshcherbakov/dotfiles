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

### Соглашение о зависимостях таргетов

В prerequisites `install-*` таргета указываются только зависимости, **общие для всех поддерживаемых ОС** (например `install-stow`, `install-curl`). Зависимость, нужную лишь на конкретной ОС, доустанавливает сам скрипт `script/*.sh`, а не Makefile.

Причина: общий prerequisite тянул бы лишнее на другую систему. Например, `snap` нужен для части LSP-серверов только на Linux Mint — вынеси мы его в prerequisites, он пытался бы ставиться и на Arch, где не нужен (а `script/snap.sh` там и вовсе завершается ошибкой). Поэтому системно-специфичные зависимости скрипт ставит у себя (обычно через `script/install_by_package_manager.sh`).

### AUR-хелпер: почему `yay`, а не `pamac`

Для установки пакетов из AUR (pyright, cmake-language-server) используется `yay`, а не Manjaro-шный `pamac`.

Причина: скрипты различают ОС по файлу `/etc/arch-release`, который есть **и в Arch, и в Manjaro** — одна ветка кода обслуживает обе системы. `yay` ставится на любом Arch-подобном дистрибутиве, тогда как `pamac` существует только в Manjaro (пакета `pamac-cli` нет в официальных репозиториях чистого Arch — он живёт в AUR). Замена `yay` на `pamac` сломала бы установку на ванильном Arch. Если когда-нибудь поддержку чистого Arch решат убрать (см. `TODO: check for Manjaro` в `script/preinstall.sh`), переход на `pamac` станет уместным.

## Обслуживание системы

Три команды, которыми обновляется и чистится система, и их аналоги по ОС:

| Назначение | Linux Mint (apt) | Arch (yay/pacman) | Manjaro (pamac) |
|------------|------------------|-------------------|-----------------|
| Обновить базы пакетов | `sudo apt update` | _входит в `yay -Syu`_ | _входит в `pamac upgrade`_ |
| Обновить пакеты | `sudo apt upgrade` | `yay -Syu` | `pamac upgrade -a` |
| Удалить ненужные пакеты | `sudo apt autoremove` | `yay -Yc` | `pamac remove --orphans` |

На Arch/Manjaro рефреш баз делается автоматически перед апгрейдом (`-y` в `yay -Syu`, авто-рефреш в `pamac`), поэтому отдельный аналог `apt update` обычно не нужен; принудительно — `sudo pacman -Sy` или `pamac upgrade --force-refresh`.

«Ненужные пакеты» (orphans) — это пакеты, поставленные как зависимость и больше никому не нужные. Помимо `yay -Yc` их можно удалить через pacman напрямую:

```bash
sudo pacman -Rns $(pacman -Qtdq)
```

> В fish подстановка пишется без `$`: `sudo pacman -Rns (pacman -Qtdq)`.

## Конфигурации

| Директория | Описание |
|------------|----------|
| `nvim/` | Neovim — Lazy.nvim, LSP, Telescope, Treesitter, blink.cmp, render-markdown |
| `tmux/` | Tmux — TPM, nord-tmux, tmux-resurrect |
| `fish/` | Fish shell — vi-mode, fzf, Oh-My-Fish |
| `alacritty/` | Alacritty — JetBrainsMono Nerd Font, tokyonight |
| `lazygit/` | Lazygit — кастомные команды |
| `lf/` | lf — файловый менеджер |
| `gdb/` | GDB — Qt5/STL printers, GDB Dashboard |
| `claude/` | Claude Code — settings.json, commands, hooks, skills |

## Шрифты

- **JetBrainsMono Nerd Font** — основной моноширинный шрифт, ставится через `make install-fish` (см. `script/fish.sh`).
- **Noto Color Emoji** — emoji-шрифт для корректного отображения pictographic-символов (U+1F300–1FAFF, U+2600–27BF) в терминале вместо tofu-квадратов. Ставится отдельно: `make install-emoji-fonts`.

## Инструменты разработки

**LSP-серверы:** clangd, gopls, pyright, lua_ls, bashls, ts_ls, cmake, csharp_ls

**Утилиты:** ripgrep, fd, fzf, bat, jq, ninja, cmake, mold, direnv, tree-sitter-cli

**Форматирование:** Stylua (Lua)

## Ключевые биндинги

- Neovim leader: `;`
- Tmux prefix: `Ctrl+A`
- Vi-style навигация во всех инструментах
