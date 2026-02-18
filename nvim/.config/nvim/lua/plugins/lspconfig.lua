local M = {
  "neovim/nvim-lspconfig",
  dependencies = { "ray-x/lsp_signature.nvim" },
}

function M.config()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Optional: if you still have nvim-cmp installed, use its capabilities helper.
  local has_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if has_cmp_nvim_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  local function default_lsp_attach_handler(_, bufnr)
    require("lsp_signature").on_attach({}, bufnr)
    require("sinbizkit.lsp.mappings").map_buf()
  end

  local servers = { "clangd", "gopls", "cmake", "pyright", "bashls", "ts_ls", "lua_ls", "csharp_ls" }

  -- Defaults for all servers you enable.
  vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = default_lsp_attach_handler,
  })

  -- Per-server overrides.
  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=never",
      "--header-insertion-decorators=false",
      "--completion-style=detailed",
    },
    on_attach = function(client, bufnr)
      default_lsp_attach_handler(client, bufnr)
      require("sinbizkit.keymap").map("n", "<Leader>gs", function()
        local params = { uri = vim.uri_from_bufnr(0) }
        vim.lsp.buf_request(0, "textDocument/switchSourceHeader", params, function(err, result)
          if err then
            vim.notify(tostring(err), vim.log.levels.ERROR)
            return
          end
          if not result then
            vim.notify("Corresponding file can't be determined", vim.log.levels.WARN)
            return
          end
          vim.cmd("edit " .. vim.uri_to_fname(result))
        end)
      end)
    end,
  })

  vim.lsp.config("gopls", {
    settings = {
      gopls = {
        semanticTokens = true,
        usePlaceholders = true,
      },
    },
  })

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
        },
        telemetry = { enable = false },
      },
    },
    on_attach = function(client, bufnr)
      default_lsp_attach_handler(client, bufnr)
      -- formatting provided by stylua (null-ls)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })

  -- Enable the servers so they auto-attach for their filetypes/root markers.
  vim.lsp.enable(servers)
end

return M
