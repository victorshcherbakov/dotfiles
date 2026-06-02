return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      on_highlights = function(h, _)
        h["@type.qualifier"] = { link = "@keyword" }
        -- All C/C++ static functions, methods and variables in purple (clangd semantic tokens)
        local static_purple = "#8b5cf6"
        h["@lsp.typemod.function.static"] = { fg = static_purple }
        h["@lsp.typemod.method.static"] = { fg = static_purple }
        h["@lsp.typemod.variable.static"] = { fg = static_purple }
        -- Namespace names in pure green (c.green is a pale lime #c3e88d, reads as gold):
        -- clangd semantic token (usages) + treesitter capture (declaration)
        local ns_green = "#00ff00"
        h["@lsp.type.namespace"] = { fg = ns_green }
        h["@module.cpp"] = { fg = ns_green }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd [[colorscheme tokyonight]]
    end,
  },
}
