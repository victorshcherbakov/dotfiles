local lspconfig = require 'lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local servers = { 'clangd', 'gopls', 'cmake', 'pylsp', 'bashls', 'tsserver' }
local configs = {
  clangd = { capabilities = capabilities },
}

-- Returns configuration for provided `server` if found, empty value otherwise.
local configOrDefault = function(server)
  local config = configs[server]
  if config == nil then
    return {}
  end
  return config
end

if (vim.fn.has('mac')) then
  table.insert(servers, 'sourcekit')
  configs['sourcekit'] = { filetypes = { "swift", "objective-c", "objective-cpp" } }
end

for _, server in ipairs(servers) do
  local config = configOrDefault(server)
  lspconfig[server].setup(config)
end

