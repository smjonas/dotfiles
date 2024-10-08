local default_on_attach = require("plugins.lsp.on_attach").attach

-- Only use ruff for formatting
local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local settings = {
  pylsp = {
    plugins = {
      pycodestyle = {
        ignore = { "E501" },
      },
    },
  },
}

return { settings = settings, on_attach = on_attach }
