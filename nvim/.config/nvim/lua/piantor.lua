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

-- <C-e>
M.cmp_previous = function(cmp, luasnip)
  return cmp.mapping(function(fallback)
    if luasnip.choice_active() and luasnip.expand_or_locally_jumpable() then
      luasnip.change_choice(-1)
    elseif cmp.visible() then
      cmp.select_prev_item()
    else
      fallback()
    end
  end, { "i", "s" })
end

local function set_override_mappings()
  local normal_mode_overrides = {
    ["<leader>n"] = "<cmd>cprev<cr>",
    ["<leader>e"] = "<cmd>cnext<cr>",
    ["<leader>ri"] = "<leader>rc",
    ["<leader>fu"] = "<leader>fc",
    -- Go to definition
    ["<leader>gt"] = "<leader>gd",
    ["<C-m>"] = vim.diagnostic.goto_prev,
    ["<C-i>"] = vim.diagnostic.goto_next,
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
