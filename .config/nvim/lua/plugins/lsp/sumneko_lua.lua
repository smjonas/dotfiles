local settings = {
  Lua = {
    diagnostics = {
      -- Fix undefined globals warnings
      globals = { 'vim', 'describe', 'it' }
    },
    telemetry = {
      enable = false
    }
  }
}

return { settings = settings }
