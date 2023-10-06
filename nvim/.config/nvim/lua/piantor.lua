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

local function set_override_mappings()
  local normal_mode_overrides = {
    ["<leader>ri"] = "<leader>rc",
  }
  local insert_mode_overrides = {
    ["<a-m>"] = "<left>",
    ["<a-n>"] = "<down>",
    ["<a-e>"] = "<up>",
    ["<a-i>"] = "<right>",
  }
  for k, v in pairs(normal_mode_overrides) do
    vim.keymap.set("n", k, v, { remap = true })
  end
  for k, v in pairs(insert_mode_overrides) do
    vim.keymap.set("i", k, v, { remap = true })
  end
end

set_override_mappings()

return M
