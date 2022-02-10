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
      globals = { "vim", "describe", "it", "setup", "before_each" },
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

return { settings = settings }
