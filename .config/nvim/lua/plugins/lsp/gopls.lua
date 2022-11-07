local default_on_attach = require("plugins.lsp.on_attach")

local settings = {
  gopls = {
    hints = {
      assignVariableTypes = true,
      compositeLiteralFields = true,
      compositeLiteralTypes = true,
      constantValues = true,
      functionTypeParameters = true,
      parameterNames = true,
      rangeVariableTypes = true,
    },
  },
}

local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  require("inlay-hints").on_attach(client, bufnr)
end

return { settings = settings, on_attach = on_attach }
