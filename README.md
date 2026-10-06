# Dotfiles

Персональные dotfiles, управляемые через [GNU Stow](https://www.gnu.org/software/stow/).

## Поддерживаемые ОС

- Arch Linux / Manjaro
- Linux Mint 22
- Windows 10 — только пакет `claude/`, см. [Windows](#windows)

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

- `install_by_package_manager.sh` — обёртка над apt для установки системных пакетов; уже установленное пропускает (по `dpkg-query`, с откатом на поиск бинарника), поэтому таргет, у которого все зависимости на месте, не спрашивает пароль sudo и не трогает пакет, поставленный мимо apt — например `bat`/`fd` из GitHub-релиза
- `install_from_github_archive.sh` — скачивает последний tar.gz-релиз с GitHub в `~/.local/bin/`
- `install_from_github_deb.sh` — скачивает последний .deb-релиз с GitHub и устанавливает его

Бинарники, устанавливаемые не через пакетный менеджер, кладутся в `~/.local/bin/`. Исключение — `script/lsp_lua.sh`: архив lua-language-server не содержит верхнего каталога (`bin/`, `main.lua`, `meta/` лежат в корне), поэтому распаковывается в собственный каталог `~/.local/share/lua-language-server/`, а в `~/.local/bin/` кладётся symlink на бинарник — сервер находит свою нагрузку по реальному пути, так что запуск через ссылку работает.

### Авто-restow через git-хуки

Чтобы новые файлы конфигурации подхватывались без ручного `stow`, репозиторий содержит git-хуки в `.githooks/`. `make install-githooks` (входит в `make install`) включает их через `git config core.hooksPath .githooks`.

Хуки `post-commit`, `post-merge` и `post-checkout` вызывают общий скрипт `.githooks/restow`, который перелинковывает все пакеты (`stow --restow`). Скрипт идемпотентен, не прерывает git-операцию и пропускает пакеты, где реальный файл перекрыл бы symlink (через сухой прогон `stow -n`).

На Windows `stow` не существует, а единственный устанавливаемый там пакет — `claude/`, поэтому `restow` вызывает его собственный установщик: `powershell -File script/windows/install-claude.ps1 -Quiet`. Флаг `-Quiet` печатает только реальные изменения, так что git-операция, ничего не менявшая в конфигурации, проходит молча. Ветка выбирается по `uname -s` (`MINGW*`/`MSYS*`/`CYGWIN*`) и тихо пропускается, если нет `powershell.exe` или `cygpath`.

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

Одна ссылка из таблицы физически оказывается внутри репозитория: `~/.claude/skills` — это stow-symlink на `claude/.claude/skills/`, поэтому `~/.claude/skills/customer-reply` создаётся прямо в рабочем дереве. Содержимого скилла в репозитории при этом нет (ссылка ведёт на Диск), но сам symlink попал бы в `git status`, поэтому он перечислен в `.gitignore` — список там нужно держать в согласии с `entries` из `script/private_links.sh`. По той же причине в `.gitignore` есть `claude/.claude/skills/synced/`: туда Claude Code складывает скиллы, синхронизированные из облака.

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

## Windows

На Windows от репозитория нужен один пакет — `claude/`: те же скиллы, команды,
хуки и глобальные инструкции, что и на Linux. Всё остальное (nvim, tmux, fish и
прочее) остаётся Linux-only.

### Установка

```powershell
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1 -Check
powershell -ExecutionPolicy Bypass -File script\windows\install-claude.ps1
powershell -ExecutionPolicy Bypass -File script\windows\install-private.ps1
```

`-Check` показывает, что изменится, и ничего не трогает. Реальный файл на месте
ссылки скрипт не удаляет: он останавливается и просит убрать файл вручную, а с
`-Force` переносит его в `<имя>.bak-<метка времени>`.

Что нужно на машине:

- **Developer Mode** (Параметры → Обновление и безопасность → Для разработчиков) —
  без него обычный пользователь не может создать symlink. Проверка идёт в момент
  создания ссылки, перезагрузка не нужна.
- **Git for Windows** — в нём Git Bash, которым Claude Code выполняет хуки.
- **Python 3**, доступный через лаунчер `py`.

Установщик — не stow, а `mklink` из `cmd`: `New-Item -ItemType SymbolicLink` в
Windows PowerShell 5.1 не передаёт флаг unprivileged-create и требует админа даже
при включённом Developer Mode. Общие хелперы линковки — в `script/windows/links.ps1`.

`~/.claude/skills` остаётся **реальным** каталогом со ссылкой на каждый скилл по
отдельности: приватные скиллы с Яндекс.Диска кладутся туда же, а ссылка на
каталог целиком отправляла бы их внутрь этого публичного репозитория. Плата за
это — **новый скилл появляется только после прогона** `install-claude.ps1`,
тогда как файлы внутри `commands/` и `hooks/` подхватываются сами: эти каталоги
слинкованы целиком. Ручным прогон при этом быть не обязан — с включёнными
git-хуками (см. ниже) `.githooks/restow` запускает установщик после каждого
`pull`, `checkout` и коммита.

Переименование или удаление скилла в репозитории оставляет ссылку, которая
больше никуда не ведёт. Установщик убирает такие ссылки сам, но **только те, что
указывают внутрь этого репозитория**: битая ссылка на приватный скилл значит
лишь, что Яндекс.Диск ещё не синхронизировался, и удалять её нельзя — про неё
печатается предупреждение.

Git-хуки репозитория (авто-линковка после обновления и проверка на личные данные
перед коммитом) включаются той же командой, что и на Linux, — `make
install-githooks` на Windows недоступен:

```powershell
git config core.hooksPath .githooks
```

Яндекс.Диск на Windows синхронизируется в `%USERPROFILE%\YandexDisk` — без точки,
в отличие от Linux-клиента; `install-private.ps1` знает про это, путь
переопределяется через `-PrivateDir` или `PRIVATE_DOTFILES_DIR`.

### Что пришлось сделать кроссплатформенным

Хуки Claude Code на Windows выполняются в Git Bash, поэтому `$HOME`, пайпы и
кавычки в `settings.json` работают как на Linux. Остальное пришлось развести:

| Что | Почему | Как решено |
|-----|--------|------------|
| Интерпретатор Python | `python3` на Windows — заглушка Microsoft Store: печатает «Python» и ничего не запускает, так что shebang хука бесполезен | `hooks/py.sh` выбирает `py -3` или `python3`; все команды в `settings.json` идут через него |
| Хук на `git mv` | `jq` в Git for Windows нет | inline-однострочник вынесен в `hooks/git-mv-verify.py` |
| Уведомления | `notify-send`/`paplay` — Linux-only | `hooks/notify.py`: notify-send на Linux, toast через PowerShell на Windows |
| `usage-refresh.sh` | нет `flock` и `/proc/sys/kernel/random/uuid` | блокировка через `mkdir` (с отбраковкой залипшей старше 5 минут), uuid — из Python |
| Пути к Chrome и Яндекс.Диску | разные на двух ОС | ветки внутри `SKILL.md` соответствующих скиллов |

`settings.json` при этом остался **один** на обе ОС.

Если CLI `claude` не лежит в `PATH` (обычная ситуация при работе из расширения
VS Code), `usage-refresh.sh` тихо выходит, и поля `sess`/`week` в статуслайне
показывают `-`. Остальная строка статуса работает.

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
| `claude/` | Claude Code — settings.json, keybindings.json, commands, hooks, skills |
| `sublime/` | Sublime Text — плагин авто-reveal текущего файла в сайдбаре |

### Sublime Text

Пакет содержит один плагин — `Packages/User/reveal_in_side_bar.py`. Sublime умеет
раскрывать файл в дереве Folders только по требованию (контекстное меню → «Reveal in
Side Bar»), встроенной настройки «всегда показывать текущий файл» у него нет. Плагин
подписывается на `on_activated_async` и вызывает эту же команду сам, так что при
переключении буферов дерево следует за курсором, как в сайдбаре по умолчанию ожидаешь.

Команда не запускается, когда сайдбар скрыт (иначе она бы его открывала) и для
буферов без пути на диске — панель поиска, консоль. Файл вне открытых папок проекта
Sublime игнорирует сам, корень дерева при этом не меняется.

Сам редактор ставится из AUR (`sublime-text-4`) на Arch/Manjaro и из apt-репозитория
sublimehq на Linux Mint — `script/sublime.sh` при первом запуске регистрирует ключ и
source list вендора.

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

**LSP-серверы:** таргеты ставят clangd (`install-clang`), pyright (`install-lsp-python`), lua_ls (`install-lsp-lua`), bashls (`install-lsp-bash`), csharp_ls (`install-lsp-csharp`). В `nvim/.config/nvim/lua/plugins/lspconfig.lua` включены ещё `gopls`, `ts_ls` и `cmake`, но установки для них в репозитории нет: таргетов под gopls и ts_ls не существует вовсе, а `script/lsp_cmake.sh` вне Arch печатает TODO и выходит. Пока такой сервер не поставлен руками, Neovim его просто не найдёт.

**Утилиты:** ripgrep, fd, fzf, bat, jq, xclip, xdotool, ninja, cmake, mold, direnv, tree-sitter-cli

`xclip` — X11-клипборд для tmux и Claude Code (вставка картинок по Ctrl+V); при переезде на Wayland в `script/xclip.sh` добавить `wl-clipboard`. Внутри tmux xclip нужен `DISPLAY`, а панель, созданная, пока к сессии был подключён клиент без X (tty, ssh), остаётся без него навсегда — tmux обновляет окружение сессии при attach, но не окружение уже запущенных шеллов. `fish/.config/fish/conf.d/tmux_env.fish` перед каждой командой перечитывает `DISPLAY`/`XAUTHORITY`/`WAYLAND_DISPLAY`/`XDG_SESSION_TYPE` из `tmux show-environment`.

`xdotool` — X11-автоматизация. Используется в `config.fish` как обход регрессии Muffin ≥ 6.6.0 (WM в Cinnamon): новое окно Alacritty поднимается наверх, но без клавиатурного фокуса, и shell не принимает ввод, пока не кликнешь внутрь. Хук в `config.fish` повторно активирует окно по `$ALACRITTY_WINDOW_ID`. Ставится в `script/fish.sh`; X11-only, для Wayland потребуется аналог (`ydotool`/`wtype`).

**Форматирование:** Stylua (Lua)

## Ключевые биндинги

- Neovim leader: `;`
- Tmux prefix: `Ctrl+A`
- Vi-style навигация во всех инструментах
