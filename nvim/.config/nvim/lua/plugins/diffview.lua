local M = {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    "<Leader>ho",
    "<Leader>hc",
    "<Leader>hf",
    "<Leader>hF",
    "<Leader>hq",
  },
}

function M.config()
  require("diffview").setup {
    view = {
      -- diff2_horizontal puts old | new in side-by-side columns (GitHub split).
      default = { layout = "diff2_horizontal" },
      file_history = { layout = "diff2_horizontal" },
    },
  }

  local km = require "sinbizkit.keymap"
  km.map("n", "<Leader>ho", "<Cmd>DiffviewOpen<CR>",
    { desc = "Diffview: working tree vs index" })
  km.map("n", "<Leader>hc", "<Cmd>DiffviewOpen HEAD~1<CR>",
    { desc = "Diffview: last commit" })
  km.map("n", "<Leader>hf", "<Cmd>DiffviewFileHistory %<CR>",
    { desc = "Diffview: current file history" })
  km.map("n", "<Leader>hF", "<Cmd>DiffviewFileHistory<CR>",
    { desc = "Diffview: repository history" })
  km.map("n", "<Leader>hq", "<Cmd>DiffviewClose<CR>",
    { desc = "Diffview: close" })
end

return M
