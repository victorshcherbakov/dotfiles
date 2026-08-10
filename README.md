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
make install-grub-hook
```

Приватные файлы, которых нет в репозитории (см. ниже) — отдельным таргетом, он не входит в `make install`:

```bash
make install-private
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

Каждый таргет `make install-*` запускает скрипт установки из `script/*.sh`, а затем `stow --target=$HOME <dir>` для инструментов с конфигурационными директориями. `script/preinstall.sh` определяет ОС — Arch/Manjaro (pacman/yay) или Linux Mint 22 (apt) — и запускает обновление системы. Общие хелперы:

- `install_by_package_manager.sh` — обёртка над apt для установки системных пакетов
- `install_from_github_archive.sh` — скачивает последний tar.gz-релиз с GitHub в `~/.local/bin/`
- `install_from_github_deb.sh` — скачивает последний .deb-релиз с GitHub и устанавливает его

Бинарники, устанавливаемые не через пакетный менеджер, кладутся в `~/.local/bin/`.

### Авто-restow через git-хуки

Чтобы новые файлы конфигурации подхватывались без ручного `stow`, репозиторий содержит git-хуки в `.githooks/`. `make install-githooks` (входит в `make install`) включает их через `git config core.hooksPath .githooks`.

Хуки `post-commit`, `post-merge` и `post-checkout` вызывают общий скрипт `.githooks/restow`, который перелинковывает все пакеты (`stow --restow`). Скрипт идемпотентен, не прерывает git-операцию и пропускает пакеты, где реальный файл перекрыл бы symlink (через сухой прогон `stow -n`).

Важная деталь stow: подкаталоги вроде `~/.config/nvim` или `~/.claude/commands` — это symlink'и на каталог целиком, поэтому **новый файл внутри уже застоуленного каталога появляется автоматически**, без хука. Хуки нужны для нового файла на верхнем уровне пакета (например, новый top-level файл в `~/.claude/`, который линкуется поштучно).

### Проверка на личные данные перед коммитом

Репозиторий публичный, а запушенная строка остаётся доступной по SHA даже после force-push — поэтому `.githooks/pre-commit` сканирует **добавляемые** строки и отклоняет коммит, если в них нашлись приватные ключи, API-токены, email-адреса или адреса из приватных подсетей. Ложное срабатывание обходится через `git commit --no-verify`.

Слова, специфичные для конкретной машины (домен работодателя, внутренний хост, префикс тикетов), в репозитории **не хранятся** — иначе публичный блоклист сам раскрывал бы то, что скрывает. Хук читает их из `.git/secret-patterns` (git его не отслеживает), а туда файл приходит с Яндекс.Диска через `make install-private`. Формат — по одному POSIX ERE на строку (`\b` не поддерживается, регистр учитывается), опционально `<regex><TAB><метка>`; образец с примерами — `.githooks/secret-patterns.example`.

Если блоклиста нет или symlink на него битый, хук **отклоняет коммит**, а не проверяет молча по одним generic-паттернам: наполовину проверенный коммит выглядит как проверенный. Обход — `git commit --no-verify`.

### Приватные файлы на Яндекс.Диске

Часть конфигурации не может лежать в публичном репозитории, но нужна на каждой рабочей машине. Такие файлы живут в `~/Yandex.Disk/private/dotfiles/` (Диск синхронизирует их между машинами), а `make install-private` расставляет symlink'и оттуда по местам:

| Источник на Диске | Куда линкуется | Что это |
|-------------------|----------------|---------|
| `secret-patterns` | `.git/secret-patterns` | блоклист для `pre-commit` |
| `claude-private.md` | `~/.claude/private.md` | приватная часть глобальных инструкций Claude, подключается из `claude/.claude/AGENTS.md` через `@~/.claude/private.md` |
| `skills/customer-reply` | `~/.claude/skills/customer-reply` | скилл с внутренним рабочим процессом |
| `ssh_config_private` | — | блок `Host` для приватного GitLab; читается `script/ssh.sh` прямо с Диска |

Скрипт `script/private_links.sh` падает с ошибкой, если каталога или любого файла нет, и никогда не удаляет реальный файл, чтобы поставить на его место symlink — вместо этого сообщает, что файл нужно убрать вручную. Путь переопределяется переменной `PRIVATE_DOTFILES_DIR`.

Таргет намеренно не входит в `make install`: на свежей машине Диск может быть ещё не синхронизирован, а таргет по замыслу падает, а не линкует половину.

### Системный pacman-хук: регенерация GRUB (только Arch)

На Arch/Manjaro конфиг GRUB (`/boot/grub/grub.cfg`) **не** перегенерируется автоматически при установке/обновлении/удалении ядра, из-за чего после апдейта может остаться ссылка на несуществующую версию ядра и система не загрузится. Чтобы этого не было, репозиторий содержит pacman-хук `pacman-hooks/99-grub-mkconfig.hook`, который после любой такой транзакции запускает `grub-mkconfig -o /boot/grub/grub.cfg`.

Файл живёт в `/etc/pacman.d/hooks/`, а не в `$HOME`, поэтому он не управляется stow. `make install-grub-hook` (входит в `make install`) копирует его туда через `sudo install`. На apt-системах хук не нужен и скрипт `script/grub_hook.sh` просто завершается без действий.

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
| `nvim/` | Neovim — Lazy.nvim, LSP, Telescope, Treesitter, blink.cmp, render-markdown, gitsigns + Diffview |
| `tmux/` | Tmux — TPM, nord-tmux, tmux-resurrect |
| `fish/` | Fish shell — vi-mode, fzf, Oh-My-Fish |
| `alacritty/` | Alacritty — JetBrainsMono Nerd Font, tokyonight |
| `lazygit/` | Lazygit — кастомные команды |
| `lf/` | lf — файловый менеджер |
| `gdb/` | GDB — Qt5/STL printers, GDB Dashboard |
| `claude/` | Claude Code — settings.json, commands, hooks, skills |

### Neovim

Точка входа `nvim/.config/nvim/init.lua` загружает модули по порядку: `options` → `mappings` → `plugin` → `sinbizkit.lsp`.

- **Плагины:** Lazy.nvim, bootstrap в `lua/plugin.lua`; спецификации в `lua/plugins/` (один файл на плагин или группу).
- **LSP:** современный API `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.11+), а НЕ устаревший `require('lspconfig')`. Серверы настроены в `lua/plugins/lspconfig.lua`.
- **Форматирование:** Stylua через conform.nvim; у lua_ls форматирование отключено, чтобы избежать конфликтов.
- **Кастомные модули `lua/sinbizkit/`:** `lsp/mappings.lua` — LSP-биндинги при подключении к буферу, `keymap.lua` — хелпер для определения клавиш, `telescope/vimconf_picker.lua` — кастомный Telescope picker, `snippets/` — LuaSnip-сниппеты для cpp/go/lua.
- **Отступы по языкам:** переопределения в `nvim/.config/nvim/after/ftplugin/`.

## Шрифты

- **JetBrainsMono Nerd Font** — основной моноширинный шрифт, ставится через `make install-fish` (см. `script/fish.sh`).
- **Noto Color Emoji** — emoji-шрифт для корректного отображения pictographic-символов (U+1F300–1FAFF, U+2600–27BF) в терминале вместо tofu-квадратов. Ставится отдельно: `make install-emoji-fonts`.

## Инструменты разработки

**LSP-серверы:** clangd, gopls, pyright, lua_ls, bashls, ts_ls, cmake, csharp_ls

**Утилиты:** ripgrep, fd, fzf, bat, jq, xclip, xdotool, ninja, cmake, mold, direnv, tree-sitter-cli

`xclip` — X11-клипборд для tmux и Claude Code (вставка картинок по Ctrl+V); при переезде на Wayland в `script/xclip.sh` добавить `wl-clipboard`.

`xdotool` — X11-автоматизация. Используется в `config.fish` как обход регрессии Muffin ≥ 6.6.0 (WM в Cinnamon): новое окно Alacritty поднимается наверх, но без клавиатурного фокуса, и shell не принимает ввод, пока не кликнешь внутрь. Хук в `config.fish` повторно активирует окно по `$ALACRITTY_WINDOW_ID`. Ставится в `script/fish.sh`; X11-only, для Wayland потребуется аналог (`ydotool`/`wtype`).

**Форматирование:** Stylua (Lua)

## Ключевые биндинги

- Neovim leader: `;`
- Tmux prefix: `Ctrl+A`
- Vi-style навигация во всех инструментах
