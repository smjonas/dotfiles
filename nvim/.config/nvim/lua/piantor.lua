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

function M.mini_move_mappings()
  local mappings = {
    left = { "<M-h>", "<M-m>" },
    right = { "<M-j>", "<M-i>" },
    down = { "<M-k>", "<M-n>" },
    up = { "<M-l>", "<M-e>" },
    line_left = { "<M-h>", "<M-m>" },
    line_right = { "<M-j>", "<M-i>" },
    line_down = { "<M-k>", "<M-n>" },
    line_up = { "<M-l>", "<M-e>" },
  }
  local effective_mappings = {}
  for k, v in pairs(mappings) do
    effective_mappings[k] = v[1]
  end
  return { mappings = effective_mappings }
end

local config_root = vim.fn.stdpath("config")

local override_mappings = {
  { "n", default_lhs = "<leader>j", piantor_lhs = "<leader>l", cmd = "<cmd>cprev<cr>" },
  { "n", default_lhs = "<leader>k", piantor_lhs = "<leader>e", cmd = "<cmd>cnext<cr>" },
  { "n", default_lhs = "<C-j>", piantor_lhs = "<C-m>", cmd = vim.diagnostic.goto_prev },
  { "n", default_lhs = "<C-k>", piantor_lhs = "<C-i>", cmd = vim.diagnostic.goto_next },
  {
    "n",
    default_lhs = "<leader>gd",
    piantor_lhs = "<leader>gt",
    cmd = function()
      require("plugins.lsp.on_attach").go_to_definition()
    end,
    desc = "Go to definition",
  },
  {
    "n",
    default_lhs = "<leader>rc",
    piantor_lhs = "<leader>ri",
    cmd = function()
      vim.cmd.edit(("%s/init.lua"):format(config_root))
    end,
    desc = "Edit init.lua",
  },
  {
    "n",
    default_lhs = "<leader>fc",
    piantor_lhs = "<leader>fu",
    cmd = function()
      require("plugins.telescope").find_config()
    end,
    desc = "[f]ind in Neovim [c]onfig files",
  },
  { "i", default_lhs = "<C-h>", piantor_lhs = "<C-m>", cmd = "<left>" },
  { "i", default_lhs = "<C-l>", piantor_lhs = "<C-i>", cmd = "<right>" },
  { "i", default_lhs = "<C-j>", piantor_lhs = "<C-e>", cmd = "<up>" },
  { "i", default_lhs = "<C-k>", piantor_lhs = "<C-n>", cmd = "<down>" },
}

M.apply_mappings = function(do_override_mappings)
  if not do_override_mappings then
    -- Mappings are already applied in the respective config files,
    -- "hot reloading" is not currently supported
    return
  end

  for _, mapping in ipairs(override_mappings) do
    local lhs = mapping.piantor_lhs
    vim.keymap.set(mapping[1], lhs, mapping.cmd, { silent = true, desc = mapping.desc })
  end
end

return M
