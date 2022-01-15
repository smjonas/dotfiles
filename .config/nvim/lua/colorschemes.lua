return {
  {
    "sainnhe/edge",
    config = function()
      vim.g["edge_enable_italic"] = 1
      vim.g["edge_disable_italic_comment"] = 1
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd("colorscheme kanagawa")
    end
  },
  {
    "sainnhe/gruvbox-material",
    setup = function()
      vim.g.gruvbox_material_palette = "mix"
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_transparent_background = 0
    end,
  },
  { "ghifarit53/tokyonight-vim" },
  {
    "navarasu/onedark.nvim",
    setup = function()
      vim.g.onedark_style = "warmer"
    end,
  },
}
