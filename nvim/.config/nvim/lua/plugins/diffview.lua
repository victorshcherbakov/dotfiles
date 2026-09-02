local M = {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    "<Leader>ho",
    "<Leader>hc",
    "<Leader>hm",
    "<Leader>hM",
    "<Leader>hf",
    "<Leader>hF",
    "<Leader>hq",
  },
}

function M.config()
  local actions = require "diffview.actions"

  require("diffview").setup {
    view = {
      -- diff2_horizontal puts old | new in side-by-side columns (GitHub split).
      default = { layout = "diff2_horizontal" },
      file_history = { layout = "diff2_horizontal" },
    },
    file_panel = {
      win_config = { width = 70 },
    },
    keymaps = {
      file_history_panel = {
        -- Override the default 'o' (select_entry, still on <cr>/l) so it opens the
        -- commit under the cursor as a full Diffview with the changed-files panel.
        { "n", "o", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
        { "n", "<C-A-d>", false },
      },
    },
  }

  local km = require "sinbizkit.keymap"
  km.map("n", "<Leader>ho", "<Cmd>DiffviewOpen<CR>",
    { desc = "Diffview: working tree vs index" })
  km.map("n", "<Leader>hc", "<Cmd>DiffviewOpen HEAD~1<CR>",
    { desc = "Diffview: last commit" })
  -- Three dots: the left side is the merge-base, so the diff holds only what this branch did.
  -- Two dots would also drag in every master commit made since, inverted.
  -- --imply-local puts the working tree on the right, so uncommitted edits show up too.
  km.map("n", "<Leader>hm", "<Cmd>DiffviewOpen origin/master...HEAD --imply-local<CR>",
    { desc = "Diffview: this branch since merge-base" })
  km.map("n", "<Leader>hM", "<Cmd>DiffviewOpen origin/master...HEAD<CR>",
    { desc = "Diffview: this branch since merge-base, committed only" })
  km.map("n", "<Leader>hf", "<Cmd>DiffviewFileHistory %<CR>",
    { desc = "Diffview: current file history" })
  km.map("n", "<Leader>hF", "<Cmd>DiffviewFileHistory<CR>",
    { desc = "Diffview: repository history" })
  km.map("n", "<Leader>hq", "<Cmd>DiffviewClose<CR>",
    { desc = "Diffview: close" })
end

return M
