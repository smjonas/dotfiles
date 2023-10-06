local M = {}

-- <C-s>
M.cmp_confirm = function(cmp)
  return cmp.mapping(
    cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    { "i", "s" }
  )
end

local function override_mappings()
  local overrides = {
    ["<leader>ri"] = "<leader>rc",
  }
  for k, v in pairs(overrides) do
    vim.keymap.set("n", k, v, { remap = true })
  end
end

override_mappings()

return M
