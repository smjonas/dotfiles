local default_on_attach = require("plugins.lsp.on_attach")

-- Only use null-ls for formatting
local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false
end

return { on_attach = on_attach }
