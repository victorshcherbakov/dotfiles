local km = require "sinbizkit.keymap"

km.map("n", "<C-s>", ":wa<CR><CR>", { desc = 'Save all the modified documents' })

-- {{{ Motions
km.map("n", "<", ",")
km.map("n", ">", ";")
-- }}}

-- {{{ Buffer modification
km.map("n", "<Leader>q", ":bp|bd #<CR>", { desc = 'Close the current buffer' })
km.map("n", "J", ":m .+1<CR>==", { desc = 'Move current line down' })
km.map("n", "K", ":m .-2<CR>==", { desc = 'Move current line up' })
km.map("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move selected block down' })
km.map("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move selected block up' })
km.map("v", "<C-c>", "\"+y", { desc = 'Copy to the Clipboard Buffer' })
km.map("n", "<C-v>", "\"+p", { desc = 'Paste from the Clipboard Buffer' })
-- }}}

-- {{{ Tabs moving
km.map("n", "<M-j>", "<Cmd>-tabmove<CR>", { desc = 'Move current tab page to the left' })
km.map("n", "<M-k>", "<Cmd>+tabmove<CR>", { desc = 'Move current tab page to the right' })
-- }}}

-- {{{ Tabs navigation
km.map("n", "<M-h>", "<Cmd>tabprevious<CR>", { desc = 'Move current tab page to the left' })
km.map("n", "<M-l>", "<Cmd>tabnext<CR>", { desc = 'Move current tab page to the right' })
-- }}}

-- {{{ Panes creation
km.map("n", "<Space>e", "<Cmd>vsplit<CR>", { desc = 'Split current window vertically' })
km.map("n", "<Space>o", "<Cmd>split<CR>", { desc = 'Split current window horizontally' })
km.map("n", "<Space>t", "<Cmd>tabnew<CR>", { desc = 'Open new tab' })
-- }}}
--
-- {{{ Panes navigation.
km.map("n", "<C-J>", "<C-W><C-J>")
km.map("n", "<C-K>", "<C-W><C-K>")
km.map("n", "<C-L>", "<C-W><C-L>")
km.map("n", "<C-H>", "<C-W><C-H>")
-- }}}

-- {{{ Tags.
km.map("n", "<Leader>]n", "<Cmd>tnext<CR>")
km.map("n", "<Leader>]p", "<Cmd>tprevious<CR>")
-- }}}

-- {{{ QuickFix.
km.map("n", "<Leader>oq", "<Cmd>copen<CR>")
km.map("n", "<Leader>nq", "<Cmd>cnext<CR>")
km.map("n", "<Leader>pq", "<Cmd>cprevious<CR>")
-- }}}

-- {{{ LocationList.
km.map("n", "<Leader>ol", "<Cmd>lopen<CR>")
km.map("n", "<Leader>nl", "<Cmd>lnext<CR>")
km.map("n", "<Leader>pl", "<Cmd>lprevious<CR>")
-- }}}
