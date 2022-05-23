local default_on_attach = require("plugins.lsp.on_attach")

local settings = {
  Lua = {
    runtime = {
      version = "LuaJIT",
    },
    completion = {
      callSnippet = "Replace",
    },
    diagnostics = {
      -- Fix undefined globals warnings
      globals = { "vim", "describe", "it", "setup", "before_each", "stub" },
    },
    workspace = {
      library = {
        vim.fn.expand("$VIMRUNTIME/lua"),
        vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
      },
    },
    telemetry = {
      enable = false,
    },
  },
}

-- Only use null-ls for formatting
local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  client.server_capabilities.document_formatting = false
  client.server_capabilities.document_range_formatting = false
end

return { settings = settings, on_attach = on_attach }
