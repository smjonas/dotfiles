function _G.P(...)
  local objects = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  print(table.concat(objects, "\n"))
  return ...
end

function map(mode, lhs, rhs, opt)
  local options = { noremap = true, silent = true }
  if opt then
    options = vim.tbl_extend("force", options, opt)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify(
      "utils..safe_require: could not load module: " .. module_name,
      vim.log.levels.ERROR,
      { title = "Module Not Found" }
    )
    --   end)
    -- end, 1000)
    -- Ignore any function call on the module
    return setmetatable({}, {
      __index = function()
        return function() end
      end,
    })
  end
  return module
end
