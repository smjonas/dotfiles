local M = {}

function M.init(use)
  use {
    {
      "sainnhe/edge",
      config = function()
        vim.g["edge_enable_italic"] = 1
        vim.g["edge_disable_italic_comment"] = 1
      end
    },
    {
      "rebelot/kanagawa.nvim"
    },
    {
      "sainnhe/gruvbox-material",
      setup = function()
        vim.g.gruvbox_material_palette = "mix"
        vim.g.gruvbox_material_background = "medium"
        vim.g.gruvbox_material_transparent_background = 0
      end
    },
    { "ghifarit53/tokyonight-vim" },
    {
      "navarasu/onedark.nvim",
      setup = function() vim.g.onedark_style = "warmer" end
    }
  }
  vim.cmd("colorscheme " .. vim.g.colorscheme)
  -- vim.cmd("colorscheme edge")
  -- Better floating window colors
  local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
  local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
  vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=" .. normal_float_bg)
end

return M
