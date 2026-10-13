local lsp_progress = ""

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
    init = function()
      -- Not vim.lsp.status(): it pops the messages it reads, so every timer or
      -- CursorMoved refresh of lualine would blank the text between reports.
      vim.api.nvim_create_autocmd("LspProgress", {
        pattern = { "begin", "report", "end" },
        callback = function(event)
          local value = event.data.params.value
          lsp_progress = value.kind == "end" and "" or value.title .. (value.message and ": " .. value.message or "")
          require("lualine").refresh()
        end,
      })
    end,
    opts = {
      options = {
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "filename" }, { "diff" } },
        lualine_x = {
          {
            function()
              return lsp_progress
            end,
            -- A plain "DiagnosticWarn" links the whole group and drops the section background.
            color = function()
              return { fg = require("lualine.utils.utils").extract_highlight_colors("DiagnosticWarn", "fg") }
            end,
          },
          "encoding",
          "fileformat",
          "filetype",
        },
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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = true },
        char = { enabled = true },
      },
    },
    keys = {
      {
        "<Leader>j",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
      },
    },
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
