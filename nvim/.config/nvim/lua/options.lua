local opt = vim.opt
local g   = vim.g

opt.exrc   = true
opt.secure = true

opt.errorbells = false
opt.mouse      = 'a'

-- Disable data-loss-safety stuff. In any case an vcs will help.
opt.swapfile    = false
opt.writebackup = false
opt.backup      = false

opt.autoread = true

g.mapleader = ';'
g.loaded_ruby_provider = false

-- {{{ Appearance
opt.termguicolors = true

opt.list           = true
opt.listchars      = { tab = '•·', space = '·', eol = '↴', extends = '»', precedes = '«', trail = '~', nbsp = '⦸' }
opt.cursorline     = true     -- Highlighting that moves with the cursor.
opt.showmode       = true     -- Turn off the native mode indicator.
opt.encoding       = 'utf-8'  -- Default encoding.
opt.foldmethod     = 'indent' -- Syntax highlighting items specify folds.
opt.foldlevel      = 3        -- Close folds with the higher level.
opt.number         = true     -- Print the linenumber in front of each line.
opt.relativenumber = true     -- Show the line number relative to the line.
opt.showtabline    = 2        -- Always show the line with tab page labels.
opt.shortmess      = 'atIc'   -- Remove all useless messages.
opt.splitbelow     = true     -- Splitting will put the new window below the current one.
opt.pumheight      = 15       -- Maximum number of items showed in a popup menu.
opt.signcolumn     = 'yes'    -- Always show the sign column.

-- This will show the popup menu even if there's only one match (menuone),
-- prevent automatic selection (noselect) and prevent automatic text injection
-- into the current line (noinsert).
opt.completeopt = {'noinsert', 'menuone', 'noselect'}
opt.laststatus  = 2 -- The last window will always have a status line.

vim.cmd('silent! colorscheme dracula')

vim.cmd [[
sign define LspDiagnosticsSignError text=✘ texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text= texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=  texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=💡 texthl=LspDiagnosticsSignHint linehl= numhl=
]]

-- }}}
