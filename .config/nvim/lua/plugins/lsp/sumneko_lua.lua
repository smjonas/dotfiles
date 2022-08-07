local default_on_attach = require("plugins.lsp.on_attach")

local settings = {
  Lua = {
    runtime = {
      version = "LuaJIT",
    },
    completion = {
      callSnippet = "Replace",
      keywordSnippet = "Disable",
    },
    diagnostics = {
      -- Fix undefined globals warnings
      globals = { "vim", "describe", "it", "setup", "before_each", "stub", "mock" },
    },
    hint = {
      enable = true,
    },
    workspace = {
      library = {
        vim.fn.expand("$VIMRUNTIME/lua"),
        -- vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
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
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

return require("lua-dev").setup {
  lspconfig = { settings = settings, on_attach = on_attach, plugins = { "nvim-treesitter" } },
}
