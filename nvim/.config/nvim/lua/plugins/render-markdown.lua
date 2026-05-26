return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "kyazdani42/nvim-web-devicons",
  },
  opts = {
    completions = { lsp = { enabled = true } },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    local km = require "sinbizkit.keymap"
    km.map("n", "<Leader>mr", "<Cmd>RenderMarkdown toggle<CR>",
      { desc = "Toggle markdown rendering" })
  end,
}
