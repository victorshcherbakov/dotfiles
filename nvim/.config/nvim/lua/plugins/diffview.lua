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
    "<Leader>hg",
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
  local git = require "sinbizkit.git"
  -- A detached HEAD prints nothing, which parent_master sends to origin.
  local function upstream_master()
    local head = vim.system({ "git", "symbolic-ref", "-q", "HEAD" }, { text = true }):wait()
    return git.parent_master(vim.trim(head.stdout))
  end
  -- Three dots: the left side is the merge-base, so the diff holds only what this branch did.
  -- Two dots would also drag in every master commit made since, inverted.
  -- --imply-local puts the working tree on the right, so uncommitted edits show up too.
  km.map("n", "<Leader>hm", function() vim.cmd("DiffviewOpen " .. upstream_master() .. "...HEAD --imply-local") end,
    { desc = "Diffview: this branch since merge-base" })
  km.map("n", "<Leader>hM", function() vim.cmd("DiffviewOpen " .. upstream_master() .. "...HEAD") end,
    { desc = "Diffview: this branch since merge-base, committed only" })
  -- No --imply-local: the working tree belongs to HEAD, not to the picked branch.
  km.map("n", "<Leader>hg", function()
    require("sinbizkit.telescope.branch_picker").pick(function(branch)
      vim.cmd("DiffviewOpen " .. git.parent_master(branch.refname) .. "..." .. branch.name)
    end, git.parent_master)
  end, { desc = "Diffview: picked branch since merge-base" })
  km.map("n", "<Leader>hf", "<Cmd>DiffviewFileHistory %<CR>",
    { desc = "Diffview: current file history" })
  km.map("n", "<Leader>hF", "<Cmd>DiffviewFileHistory<CR>",
    { desc = "Diffview: repository history" })
  km.map("n", "<Leader>hq", "<Cmd>DiffviewClose<CR>",
    { desc = "Diffview: close" })
end

return M
