local default_on_attach = require("plugins.lsp.on_attach")

-- Only use null-ls for formatting
local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local settings = {
  plugins = {
    pycodestyle = {
      maxLineLength = 100,
      ["max-line-length"] = 100,
    },
  },
}

return { settings = settings, on_attach = on_attach }
