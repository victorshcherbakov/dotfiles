-- nvim-treesitter `main` branch: full rewrite, incompatible with `master`.
-- No modules, no lazy-loading. Highlight is started manually per filetype.
local parsers = {
  "c",
  "cpp",
  "c_sharp",
  "rust",
  "go",
  "lua",
  "python",
  "cmake",
  "bash",
  "javascript",
  "markdown",
  "markdown_inline",
}

-- Filetypes that should trigger `vim.treesitter.start()`.
-- Note: parser name != filetype for bash (sh) and c_sharp (cs).
local highlight_filetypes = {
  "c",
  "cpp",
  "cs",
  "rust",
  "go",
  "lua",
  "python",
  "cmake",
  "sh",
  "bash",
  "javascript",
  "markdown",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-context",
  },
  config = function()
    require("nvim-treesitter").install(parsers)

    vim.treesitter.language.register("bash", { "sh" })
    vim.treesitter.language.register("c_sharp", { "cs" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = highlight_filetypes,
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
