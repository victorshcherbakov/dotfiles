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
    km.buf_map("n", "<Leader>gn", vim.diagnostic.goto_next,
      { desc = 'Jump to the next diagnostic' }
    )
    km.buf_map("n", "<Leader>gp", vim.diagnostic.goto_prev,
      { desc = 'Jump to the previous diagnostic' }
    )

    -- d - do
    km.buf_map("n", "<Leader>di", vim.lsp.buf.code_action,
      { desc = 'Selects a code action available at the current cursor position' }
    )
    km.buf_map("n", "<Leader>dr", vim.lsp.buf.rename,
      { desc = 'Renames a symbol under cursor' }
    )
    km.buf_map({ "n", "v" }, "<Leader>df", vim.lsp.buf.format,
      { desc = 'Formats the buffer in normal mode and selected part in visual mode' }
    )

    -- lspconfig
    if pcall(require, "lspconfig") then
      km.buf_map("n", "<Leader>rl", function()
          vim.cmd [[ LspRestart ]]
          vim.notify("LSP servers are reloaded.", vim.log.levels.INFO, {
            title = "LspConfig",
            render = "compact",
          })
        end,
        { desc = 'Reloads LSP servers' }
      )
    end

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
