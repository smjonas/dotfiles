local default_on_attach = require("plugins.lsp.on_attach").attach

-- See https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json
local settings = {
  Lua = {
    single_file_support = true,
    completion = {
      callSnippet = "Both",
      keywordSnippet = "Disable",
    },
    diagnostics = {
      -- Fix undefined globals warnings
      globals = { "vim", "describe", "it", "setup", "before_each", "stub", "mock" },
    },
    -- hint = {
    --   enable = true,
    -- },
    workspace = {
      -- library = {
      -- vim.fn.expand("$VIMRUNTIME/lua"),
      -- vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
      -- },
      checkThirdParty = false,
      maxPreload = 1000,
      preloadFileSize = 150,
    },
    telemetry = {
      enable = false,
    },
  },
}

-- Only use null-ls for formatting
local on_attach = function(client, bufnr)
  default_on_attach(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

require("neodev").setup {
  library = {
    plugins = false,
  },
}
return { settings = settings, on_attach = on_attach }
