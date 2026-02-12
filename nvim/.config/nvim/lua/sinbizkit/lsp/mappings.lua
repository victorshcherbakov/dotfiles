local km = require "sinbizkit.keymap"

return {
  map_buf = function()
    -- s - show.
    km.buf_map("n", "<Leader>sh", vim.lsp.buf.hover,
      { desc = 'Displays hover information about the symbol under the cursor in a floating window. Calling the function twice will jump into the floating window' }
    )
    km.buf_map("n", "<Leader>si", vim.lsp.buf.signature_help,
      { desc = 'Displays signature information about the symbol under the cursor in a floating window' }
    )
    km.buf_map("n", "<Leader>sd", vim.diagnostic.open_float,
      { desc = '' }
    )

    -- g - go.
    km.buf_map("n", "<Leader>ge", vim.lsp.buf.declaration,
      { desc = 'Jumps to the declaration of the symbol under the cursor' }
    )
    km.buf_map("n", "<Leader>gt", vim.lsp.buf.type_definition,
      { desc = 'Jumps to the definition of the type of the symbol under the cursor' }
    )
    km.buf_map("n", "<Leader>gI", vim.lsp.buf.implementation,
      { desc = 'Lists all the implementations for the symbol under the cursor in the quickfix window' }
    )
    local function jump_with_float(count)
      return vim.diagnostic.jump({
        count = count,
        on_jump = function(diagnostic, bufnr)
          if not diagnostic then return end
          vim.diagnostic.open_float({
            bufnr = bufnr,
            scope = "cursor",
            focus = false,
          })
        end,
      })
    end

    km.buf_map("n", "<Leader>gn", function()
      local diag = jump_with_float(1)
      if diag then
        vim.api.nvim_command("normal! zz")
      end
    end, { desc = "Jump to the next diagnostic and center the line" })

    km.buf_map("n", "<Leader>gp", function()
      local diag = jump_with_float(-1)
      if diag then
        vim.api.nvim_command("normal! zz")
      end
    end, { desc = "Jump to the previous diagnostic and center the line" })


    -- d - do
    km.buf_map("n", "<Leader>di", vim.lsp.buf.code_action,
      { desc = 'Selects a code action available at the current cursor position' }
    )
    km.buf_map("n", "<Leader>dr", vim.lsp.buf.rename,
      { desc = 'Renames a symbol under cursor' }
    )
    km.buf_map({ "n", "v" }, "<Leader>df", function()
      local ok, conform = pcall(require, "conform")
      if ok then
        conform.format({ lsp_fallback = true, async = true })
      else
        vim.lsp.buf.format({ async = true })
      end
    end, { desc = "Formats the buffer in normal mode and selected part in visual mode (conform if available, else LSP)" })


    -- Restart LSP (without requiring deprecated `lspconfig` module).
    km.buf_map("n", "<Leader>rl", function()
        if vim.fn.has("nvim-0.11") == 1 and vim.fn.exists(":lsp") == 2 then
          vim.cmd("lsp restart")
        elseif vim.fn.exists(":LspRestart") == 2 then
          vim.cmd("LspRestart")
        end

        vim.notify("LSP servers are reloaded.", vim.log.levels.INFO, {
          title = "LspConfig",
          render = "compact",
        })
      end,
      { desc = "Reloads LSP servers" }
    )


    -- Telescope
    if pcall(require, "telescope") then
      local builtin = require "telescope.builtin"
      km.buf_map("n", "<Leader>gr", builtin.lsp_references,
        { desc = 'Lists LSP references for word under the cursor' })
      km.buf_map("n", "<Leader>gd", builtin.lsp_definitions,
        { desc = 'Goto the definition of the word under the cursor, if there`s only one, otherwise show all options in Telescope' })
      km.buf_map("n", "<Leader>gt", builtin.lsp_type_definitions,
        { desc = 'Goto the definition of the type of the word under the cursor, if there`s only one, otherwise show all options in Telescope' })
      km.buf_map("n", "<Leader>gi", builtin.lsp_implementations,
        { desc = 'Goto the implementation of the word under the cursor if there`s only one, otherwise show all options in Telescope' })
      km.buf_map("n", "<Leader>so", builtin.lsp_document_symbols,
        { desc = 'Lists LSP document symbols in the current buffer' })
      km.buf_map("n", "<Leader>ss", builtin.lsp_dynamic_workspace_symbols,
        { desc = 'Dynamically Lists LSP for all workspace symbols' })
    end
  end,
}
