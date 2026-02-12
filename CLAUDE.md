# CLAUDE.md

Этот файл содержит инструкции для Claude Code (claude.ai/code) при работе с кодом в этом репозитории.

## Язык общения

- Общение с пользователем на русском языке
- Комментарии в коде на английском языке

## Обзор

Персональные dotfiles, управляемые через GNU Stow. Поддерживаются Arch Linux/Manjaro и Linux Mint 22.

## Команды установки

```bash
make install              # Полная установка всех инструментов
make install-nvim         # Установка одного инструмента (preinstall + stow автоматически)
make install-lsp-lua      # Установка одного LSP-сервера
make clean                # Удаление всех symlink'ов stow
```

Каждый таргет `make install-*` запускает соответствующий скрипт из `script/*.sh`, а затем `stow --target=$HOME <dir>` для инструментов с конфигурационными директориями.

## Архитектура

**Управление symlink'ами через Stow:** Каждая директория верхнего уровня (nvim, tmux, fish, alacritty, lazygit, lf, gdb) зеркалирует структуру домашней директории. Например, `stow --target=$HOME nvim` создаёт symlink `nvim/.config/nvim/` → `~/.config/nvim/`.

**Система скриптов:** `script/` содержит скрипты установки для каждого инструмента. Общие хелперы:
- `install_by_package_manager.sh` — обёртка над apt для установки системных пакетов
- `install_from_github_archive.sh` — скачивает последний tar.gz-релиз с GitHub в `~/.local/bin/`
- `install_from_github_deb.sh` — скачивает последний .deb-релиз с GitHub и устанавливает его

**Определение ОС:** `script/preinstall.sh` определяет Arch (pacman/yay) или Linux Mint 22 (apt) и запускает обновление системы.

## Конфигурация Neovim

Точка входа: `nvim/.config/nvim/init.lua` загружает модули по порядку: `options` → `mappings` → `plugin` → `sinbizkit.lsp`.

**Управление плагинами:** Lazy.nvim, bootstrap в `lua/plugin.lua`. Спецификации плагинов в `lua/plugins/` (один файл на плагин или группу).

**Настройка LSP:** Используется современный API `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.11+), а НЕ устаревший `require('lspconfig')`. Настроенные серверы: clangd, gopls, cmake, pyright, bashls, ts_ls, lua_ls, csharp_ls. См. `lua/plugins/lspconfig.lua`.

**Форматирование:** Stylua для Lua через conform.nvim. У lua_ls отключено форматирование, чтобы избежать конфликтов.

**Кастомные модули в `lua/sinbizkit/`:**
- `lsp/mappings.lua` — LSP-биндинги, применяемые при подключении к буферу
- `keymap.lua` — хелпер для определения клавиш
- `telescope/vimconf_picker.lua` — кастомный Telescope picker
- `snippets/` — LuaSnip-сниппеты для cpp, go, lua

**Настройки отступов по языкам:** `nvim/.config/nvim/after/ftplugin/` содержит переопределения отступов/табов для каждого языка.

## Обязательные требования

- При любых изменениях в репозитории (добавление/удаление инструментов, изменение структуры, новые скрипты) — обновлять `README.md`, чтобы он отражал актуальное состояние проекта.

## Ключевые соглашения

- Vi-style биндинги во всех инструментах (neovim, tmux, fish)
- Leader key в Neovim: `;`
- Prefix в Tmux: `Ctrl+A`
- Бинарники устанавливаются в `~/.local/bin/`
