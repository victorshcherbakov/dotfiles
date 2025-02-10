return {

  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = {
      view = {
        adaptive_size = true,
        number = false,
        signcolumn = "no",
        relativenumber = true,
      },
      git = {
        enable = true,
        ignore = false,
      },
    },
    keys = { "<Leader>tt" },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
      local km = require "sinbizkit.keymap"
      km.map("n", "<Leader>tt", "<Cmd>NvimTreeFindFileToggle<CR>",
        { desc = "Toggle tree-view and select of the current file" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    opts = {
      options = {
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename" }, { "diff" } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = {
          { "diagnostics", sources = { "nvim_diagnostic" } },
          { "progress" },
        },
        lualine_z = { "location" },
      },

      tabline = {
        lualine_a = {
          {
            "tabs",
            max_length = vim.o.columns,
            mode = 2,
          },
        },
      },
    },
  },

  {
    "phaazon/hop.nvim",
    branch = "v2",
    keys = {
      "<Leader><Leader>w",
      "<Leader><Leader>f",
      "<Leader><Leader>b",
      "<Leader><Leader>c",
    },
    config = function()
      require("hop").setup {
        jump_on_sole_occurrence = false,
        uppercase_labels = false,
      }
      local km = require "sinbizkit.keymap"
      km.map("n", "<Leader><Leader>w", "<Cmd>HopWord<CR>")
      km.map("n", "<Leader><Leader>f", "<Cmd>HopWordAC<CR>")
      km.map("n", "<Leader><Leader>b", "<Cmd>HopWordBC<CR>")
      km.map("n", "<Leader><Leader>c", "<Cmd>HopChar1<CR>")
    end,
  },

  "tpope/vim-surround",

  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = {
        ---Line-comment toggle keymap
        line = "<Leader>cc",
        ---Block-comment toggle keymap
        block = "<Leader>bc",
      },
      opleader = {
        ---Line-comment keymap
        line = "<Leader>c",
        ---Block-comment keymap
        block = "<Leader>b",
      },
    },
  },

  {
    "simrat39/symbols-outline.nvim",
    opts = {
      auto_preview = false,
      position = "left",
      relative_width = true,
      width = 25,
      show_relative_numbers = true,
      show_symbol_details = false,
    },
    keys = "<F5>",
    config = function(_, opts)
      require("symbols-outline").setup(opts)
      local km = require "sinbizkit.keymap"
      km.map("n", "<F5>", "<Cmd>SymbolsOutline<CR>")
    end,
  },

  {
    "nvim-pack/nvim-spectre",
    keys = { "<Leader>tr" },
    config = function()
      require('spectre').setup({ is_block_ui_break = true })
      local km = require "sinbizkit.keymap"
      km.map("n", "<Leader>tr", "<Cmd>lua require('spectre').toggle()<CR>", { desc = "Toggle Spectre" })
    end,
  },

  "tpope/vim-fugitive",
}
