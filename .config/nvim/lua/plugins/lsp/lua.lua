local M = {}

function M.config()
  local settings = {
    Lua = {
      diagnostics = {
        -- Fix global vim is undefined
        globals = { 'vim' }
      },
      telemetry = {
        enable = false
      }
    }
  }
  return { settings = settings }
end

return M
