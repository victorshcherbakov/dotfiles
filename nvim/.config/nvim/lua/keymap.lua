-- A handy shorthand for vim.api.nvim_set_keymap with reasonable default opts.
local function map(modes, bind, exec, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(modes, bind, exec, options)
end

-- A handy shorthand for vim.api.nvim_buf_set_keymap with reasonable default opts.
local function buf_map(mode, bind, exec, opts)
  local options = { noremap = true, silent = true, buffer = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, bind, exec, options)
end

-- {{{ Panes creation
map("n", "ne", "<Cmd>vsplit<CR>") -- Split current window vertically.
map("n", "no", "<Cmd>split<CR>") -- Split current window horizontally.
map("n", "nt", "<Cmd>tabnew<CR>") -- Open new tab.
-- }}}
--
-- {{{ Panes navigation.
map("n", "<C-J>", "<C-W><C-J>")
map("n", "<C-K>", "<C-W><C-K>")
map("n", "<C-L>", "<C-W><C-L>")
map("n", "<C-H>", "<C-W><C-H>")
-- }}}

-- {{{ Tags.
map("n", "<Leader>]n", "<Cmd>tnext<CR>")
map("n", "<Leader>]p", "<Cmd>tprevious<CR>")
-- }}}

-- {{{ QuickFix.
map("n", "<Leader>oq", "<Cmd>copen<CR>")
map("n", "<Leader>nq", "<Cmd>cnext<CR>")
map("n", "<Leader>pq", "<Cmd>cprevious<CR>")
-- }}}

-- {{{ LocationList.
map("n", "<Leader>ol", "<Cmd>lopen<CR>")
map("n", "<Leader>nl", "<Cmd>lnext<CR>")
map("n", "<Leader>pl", "<Cmd>lprevious<CR>")
-- }}}

-- {{{ Hop plugin
map("n", "<Leader><Leader>w", "<Cmd>HopWord<CR>")
map("n", "<Leader><Leader>f", "<Cmd>HopWordAC<CR>")
map("n", "<Leader><Leader>b", "<Cmd>HopWordBC<CR>")
map("n", "<Leader><Leader>c", "<Cmd>HopChar1<CR>")
-- }}}

-- {{{ nvim-tree
map("n", "<F6>", "<Cmd>NvimTreeToggle<CR>")
map("n", "<Leader><F6>", "<Cmd>NvimTreeFindFile<CR>")
-- }}}

-- {{{ SymbolsOutline
map("n", "<F5>", "<Cmd>SymbolsOutline<CR>")
-- }}}

-- {{{ Tagbar
map("n", "<F4>", "<Cmd>TagbarToggle<CR>")
-- }}}

-- {{{ Telescope
map("n", "<Leader>t", require("telescope.builtin").find_files)
map("n", "<Leader>st", require("telescope.builtin").tags)
map("n", "<Leader>sb", require("telescope.builtin").buffers)
map("n", "<Leader>gg", require("telescope.builtin").live_grep)
map("n", "<Leader>sd", require("telescope.builtin").diagnostics)

map("n", "<Leader>v", require("sinbizkit.telescope").find_vimconf)
-- }}}

local ls = require "luasnip"
-- {{{ LuaSnips
map({ "i", "n", "s" }, "<C-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end)

map({ "i", "n", "s" }, "<C-k>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end)

map({ "i", "n", "s" }, "<C-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

-- Snippets reload.
map("n", "<Leader>rs", function()
  local path = vim.api.nvim_get_runtime_file("lua/config/plugin/luasnip.lua", false)
  if #path ~= 1 then
    error "Snippet file not found."
    return
  end
  vim.cmd("source " .. path[1])
  print "Snippets are reloaded."
end)
-- }}}

local M = {
  map = map,
  buf_map = buf_map,
}

-- Sets keybindings for interaction with LSP servers.
M.map_lsp_keys = function()
  -- s - show.
  buf_map("n", "<Leader>sh", vim.lsp.buf.hover)
  buf_map("n", "<Leader>si", vim.lsp.buf.signature_help)

  -- g - go.
  buf_map("n", "<Leader>ge", vim.lsp.buf.declaration)
  buf_map("n", "<Leader>gt", vim.lsp.buf.type_definition)
  buf_map("n", "<Leader>gI", vim.lsp.buf.implementation)
  buf_map("n", "<Leader>gn", vim.diagnostic.goto_next)
  buf_map("n", "<Leader>gp", vim.diagnostic.goto_prev)

  -- d - do
  buf_map("n", "<Leader>di", vim.lsp.buf.code_action)
  buf_map("n", "<Leader>dr", vim.lsp.buf.rename)
  buf_map("n", "<Leader>df", vim.lsp.buf.formatting)
  buf_map("v", "<Leader>df", [[<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>]])

  -- Telescope
  buf_map("n", "<Leader>gr", require("telescope.builtin").lsp_references)
  buf_map("n", "<Leader>gd", require("telescope.builtin").lsp_definitions)
  buf_map("n", "<Leader>gi", require("telescope.builtin").lsp_implementations)
  buf_map("n", "<Leader>so", require("telescope.builtin").lsp_document_symbols)
  buf_map("n", "<Leader>ss", require("telescope.builtin").lsp_dynamic_workspace_symbols)
end

return M
