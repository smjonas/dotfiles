local M = {}

function M.config()
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
end

return M
