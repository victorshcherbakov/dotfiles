# Dotfiles

Персональные dotfiles, управляемые через [GNU Stow](https://www.gnu.org/software/stow/).

## Поддерживаемые ОС

- Arch Linux / Manjaro
- Linux Mint 22
- Windows 10 — только пакет `claude/`, см. [Windows](#windows)

## Установка

```bash
make install           # всё
make install-nvim      # один инструмент: install-tmux, install-fish, install-lsp-csharp, …
make install-private   # приватные файлы с Яндекс.Диска, в make install не входит
make clean             # убрать все symlink'и
```

## Как это работает

Каждый каталог верхнего уровня зеркалирует `$HOME`, и `stow --target=$HOME <dir>` создаёт оттуда symlink'и: `nvim/.config/nvim/` → `~/.config/nvim/`, `tmux/.tmux.conf` → `~/.tmux.conf`. Таргет `make install-*` запускает свой скрипт из `script/`, затем stow. `script/preinstall.sh` определяет ОС (Arch/Manjaro — pacman/yay, Mint — apt) и обновляет систему. Бинарники не из пакетного менеджера кладутся в `~/.local/bin/`.

Правила для таргетов и скриптов:

- В prerequisites `install-*` — только зависимости, общие для всех ОС. Зависимость одной ОС ставит сам скрипт: например, `snap` нужен только на Mint, а на Arch `script/snap.sh` падает.
- AUR — через `yay`, не `pamac`: проверка `/etc/arch-release` пускает в одну ветку и Arch, и Manjaro, а `pamac` есть только в Manjaro.

### Git-хуки

`make install-githooks` (входит в `make install`) включает `.githooks/` через `core.hooksPath`.

- `post-commit`, `post-merge`, `post-checkout` вызывают `.githooks/restow`: он перелинковывает все пакеты и пропускает те, где реальный файл перекрыл бы symlink. На Windows вместо stow запускается `script/windows/install-claude.ps1 -Quiet`. Stow линкует каталог целиком, только если его ещё нет в `$HOME`; иначе файлы линкуются поштучно (сейчас так с `~/.claude/hooks`, `skills`, `commands`), и новый файл в таком каталоге появляется только после restow — то есть после коммита или ручного `stow`.
- `pre-commit` отклоняет коммит, если в добавляемых строках есть приватные ключи, токены, email или адреса приватных подсетей. Слова конкретной машины (домен работодателя, хосты) в публичном репозитории не хранятся: хук читает их из `.git/secret-patterns`, который ставит `make install-private` (формат — в `.githooks/secret-patterns.example`). Без этого файла коммит отклоняется. Обход — `git commit --no-verify`.

### Приватные файлы на Яндекс.Диске

Лежат в `~/Yandex.Disk/private/dotfiles/` (путь меняется через `PRIVATE_DOTFILES_DIR`). `make install-private` (`script/private_links.sh`) линкует их по местам; если чего-то нет — падает, а реальный файл на месте ссылки не трогает. В `make install` не входит: на свежей машине Диск может быть ещё не синхронизирован.

| Источник на Диске | Куда линкуется | Что это |
|-------------------|----------------|---------|
| `secret-patterns` | `.git/secret-patterns` | блоклист для `pre-commit` |
| `claude-private.md` | `~/.claude/private.md` | приватная часть глобальных инструкций Claude, подключается из `claude/.claude/AGENTS.md` |
| `skills/customer-reply` | `~/.claude/skills/customer-reply` | скилл с внутренним рабочим процессом |
| `ssh_config_private` | — | блок `Host` для приватного GitLab; `script/ssh.sh` читает его прямо с Диска |

Если `~/.claude/skills` — ссылка на каталог целиком, ссылки на приватные скиллы оказываются в рабочем дереве, поэтому они перечислены в `.gitignore`; этот список держать в согласии с `entries` в `script/private_links.sh`. Там же `claude/.claude/skills/synced/` — облачные скиллы Claude Code.

### pacman-хук GRUB (только Arch)

`make install-grub-hook` копирует `pacman-hooks/99-grub-mkconfig.hook` в `/etc/pacman.d/hooks/`: после установки, обновления или удаления ядра он запускает `grub-mkconfig`, иначе GRUB может ссылаться на удалённое ядро. На apt-системах скрипт ничего не делает.

## Windows

Ставится только пакет `claude/`.

```powershell
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1 -Check   # показать изменения
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1
powershell -ExecutionPolicy Bypass -File script\windows\install-private.ps1
git config core.hooksPath .githooks
```

Нужны Developer Mode (без него обычный пользователь не создаёт symlink'и), Git for Windows (Git Bash выполняет хуки Claude Code) и Python 3 с лаунчером `py`.

- Ссылки создаются через `mklink`: `New-Item -ItemType SymbolicLink` в PowerShell 5.1 требует админа даже с Developer Mode. Реальный файл на месте ссылки не удаляется; с `-Force` он переносится в `<имя>.bak-<время>`.
- `~/.claude/skills` — реальный каталог со ссылкой на каждый скилл, чтобы приватные скиллы не попадали в репозиторий. Новый скилл появляется после прогона установщика, его запускает `.githooks/restow`. Битые ссылки внутрь репозитория установщик удаляет, на приватные — только предупреждает (Диск мог ещё не синхронизироваться).
- Яндекс.Диск на Windows — `%USERPROFILE%\YandexDisk`, без точки; путь меняется через `-PrivateDir` или `PRIVATE_DOTFILES_DIR`.
- `settings.json` один на обе ОС: Python вызывается через `hooks/py.sh` (`python3` на Windows — заглушка Microsoft Store), уведомления — через `hooks/notify.py`, `jq` не используется (его нет в Git for Windows).

## Обслуживание системы

| Назначение | Linux Mint (apt) | Arch (yay/pacman) | Manjaro (pamac) |
|------------|------------------|-------------------|-----------------|
| Обновить базы пакетов | `sudo apt update` | _входит в `yay -Syu`_ | _входит в `pamac upgrade`_ |
| Обновить пакеты | `sudo apt upgrade` | `yay -Syu` | `pamac upgrade -a` |
| Удалить ненужные пакеты | `sudo apt autoremove` | `yay -Yc` | `pamac remove --orphans` |

Сироты напрямую через pacman: `sudo pacman -Rns $(pacman -Qtdq)` (в fish — без `$`).

## Конфигурации

| Директория | Описание |
|------------|----------|
| `nvim/` | Neovim — Lazy.nvim, LSP, Telescope, Treesitter, blink.cmp, render-markdown, gitsigns + Diffview |
| `tmux/` | Tmux — TPM, nord-tmux, tmux-resurrect |
| `fish/` | Fish shell — vi-mode, fzf, Oh-My-Fish |
| `alacritty/` | Alacritty — JetBrainsMono Nerd Font, tokyonight; Shift+Enter шлёт собственную последовательность `CSI 13;2u`, а tmux (`extended-keys on`) передаёт её программам, которые её просят: в Claude Code и fish это перенос строки, остальные получают обычный Enter |
| `lazygit/` | Lazygit — кастомные команды |
| `lf/` | lf — файловый менеджер |
| `gdb/` | GDB — Qt5/STL printers, GDB Dashboard |
| `claude/` | Claude Code — settings.json, keybindings.json, commands, hooks, skills |
| `sublime/` | Sublime Text — плагин авто-reveal текущего файла в сайдбаре |

### Neovim

Точка входа `init.lua` загружает `options` → `mappings` → `plugin` → `sinbizkit.lsp`.

- **Плагины:** Lazy.nvim, bootstrap в `lua/plugin.lua`, спецификации в `lua/plugins/`.
- **LSP:** API `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.11+), а НЕ устаревший `require('lspconfig')`. Серверы — в `lua/plugins/lspconfig.lua`.
- **Форматирование:** Stylua через conform.nvim; у lua_ls форматирование отключено.
- **`lua/sinbizkit/`:** LSP-биндинги, хелпер клавиш, Telescope-пикеры (в т.ч. выбор ветки: `<Leader>hg` открывает её в Diffview от merge-base с master своего remote без checkout), LuaSnip-сниппеты.
- **Отступы по языкам:** `after/ftplugin/`.

### Tmux

Когда сессия Claude Code заканчивает ответ в окне, на которое ты не смотришь, вкладка этого окна мигает жёлтым и зелёным, пока окно не выбрано. Метку `@claude_done` ставит Stop-хук `claude/.claude/hooks/tmux-claude-done.sh`; рисует и снимает её блок в конце `tmux/.tmux.conf`, цвета — в опции `@claude_tab_fg`. Блок стоит после `run tpm`, иначе nord-tmux перезапишет `window-status-format`.

### Sublime Text

`Packages/User/reveal_in_side_bar.py` раскрывает текущий файл в сайдбаре при каждом переключении буфера (встроенной настройки для этого нет); при скрытом сайдбаре и для буферов без пути не срабатывает. Редактор ставится из AUR или из apt-репозитория sublimehq (`script/sublime.sh`).

## Шрифты

- **JetBrainsMono Nerd Font** — основной, ставится через `make install-fish`.
- **Noto Color Emoji** — emoji в терминале вместо tofu-квадратов, `make install-emoji-fonts`.

## Инструменты разработки

**LSP-серверы:** clangd (`install-clang`), pyright, lua_ls, bashls, csharp_ls (`install-lsp-*`). `gopls`, `ts_ls` и `cmake` включены в `lspconfig.lua`, но ставятся руками: таргетов для gopls и ts_ls нет, а `script/lsp_cmake.sh` работает только на Arch.

**Утилиты:** ripgrep, fd, fzf, bat, jq, xclip, xdotool, ninja, cmake, mold, direnv, tree-sitter-cli. **Форматирование:** Stylua.

- `xclip` — клипборд tmux и Claude Code (вставка картинок по Ctrl+V); для Wayland добавить `wl-clipboard` в `script/xclip.sh`. В X-клипборд за одно копирование должен писать ровно один процесс, иначе Alacritty пишет «Failed to set new owner of XCB selection». Claude Code в tmux копирует дважды — своим xclip и через `tmux load-buffer -w`, который шлёт OSC 52 в терминал при любом `set-clipboard`, — поэтому локальный tmux не шлёт OSC 52 вовсе (`Ms@`) и копирует через xclip, а сервер, запущенный по ssh, оставляет OSC 52. `fish/.config/fish/conf.d/tmux_env.fish` перед каждой командой перечитывает `DISPLAY`/`XAUTHORITY`/`WAYLAND_DISPLAY`/`XDG_SESSION_TYPE` из tmux: панель, созданная при клиенте без X, иначе осталась бы без них.
- `xdotool` — в `config.fish` обходит регрессию Muffin ≥ 6.6.0 (Cinnamon): новое окно Alacritty не получает фокус клавиатуры. X11-only.

## Ключевые биндинги

- Neovim leader: `;`
- Tmux prefix: `Ctrl+A`
- Vi-style навигация во всех инструментах
