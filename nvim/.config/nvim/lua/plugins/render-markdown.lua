return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "kyazdani42/nvim-web-devicons",
  },
  opts = {
    completions = { lsp = { enabled = true } },
    pipe_table = {
      -- `overlay` keeps source column widths intact and only swaps
      -- ASCII `|`/`-` for box-drawing chars. Prevents misalignment
      -- caused by emoji, nerd-font glyphs, or ambiguous-width cells
      -- that confuse the default `padded` mode.
      cell = "overlay",
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    local km = require "sinbizkit.keymap"
    km.map("n", "<Leader>mr", "<Cmd>RenderMarkdown toggle<CR>",
      { desc = "Toggle markdown rendering" })
  end,
}
