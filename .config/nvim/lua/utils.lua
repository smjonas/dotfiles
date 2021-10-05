
local M = {}

function M.map(mode, lhs, rhs, opt)
  local options = { noremap = true, silent = true }
  if opt then
      options = vim.tbl_extend("force", options, opt)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

return M
