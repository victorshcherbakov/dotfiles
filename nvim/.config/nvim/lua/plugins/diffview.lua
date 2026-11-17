local M = {
  -- Maintained fork: upstream sindrets/diffview.nvim stopped in 06/2024 and expands every
  -- collapsed folder of the file panel on each refresh (.git/index change, save, tab enter).
  "dlyongemallo/diffview-plus.nvim",
  version = "*",
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
  -- master of the remote the branch tracks: one repository can hold unrelated histories from
  -- several remotes, and only that remote's master shares a merge-base with the branch.
  -- No upstream, a local upstream or a detached HEAD fall back to origin.
  local function upstream_master()
    local branch = vim.system({ "git", "symbolic-ref", "--short", "-q", "HEAD" }, { text = true }):wait()
    local remote = vim.system({ "git", "config", "branch." .. vim.trim(branch.stdout) .. ".remote" },
      { text = true }):wait()
    if remote.code ~= 0 or vim.trim(remote.stdout) == "." then
      return "origin/master"
    end
    return vim.trim(remote.stdout) .. "/master"
  end
  -- Three dots: the left side is the merge-base, so the diff holds only what this branch did.
  -- Two dots would also drag in every master commit made since, inverted.
  -- --imply-local puts the working tree on the right, so uncommitted edits show up too.
  km.map("n", "<Leader>hm", function() vim.cmd("DiffviewOpen " .. upstream_master() .. "...HEAD --imply-local") end,
    { desc = "Diffview: this branch since merge-base" })
  km.map("n", "<Leader>hM", function() vim.cmd("DiffviewOpen " .. upstream_master() .. "...HEAD") end,
    { desc = "Diffview: this branch since merge-base, committed only" })
  km.map("n", "<Leader>hf", "<Cmd>DiffviewFileHistory %<CR>",
    { desc = "Diffview: current file history" })
  km.map("n", "<Leader>hF", "<Cmd>DiffviewFileHistory<CR>",
    { desc = "Diffview: repository history" })
  km.map("n", "<Leader>hq", "<Cmd>DiffviewClose<CR>",
    { desc = "Diffview: close" })
end

return M
