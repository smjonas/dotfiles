return {
  {
    "sainnhe/edge",
    disable = true,
    config = function()
      vim.g["edge_enable_italic"] = 1
      vim.g["edge_disable_italic_comment"] = 1
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    disable = true,
    config = function()
      -- require("kanagawa").setup { global_status = true }
    end,
  },
  {
    "sainnhe/gruvbox-material",
    disable = true,
    setup = function()
      vim.g.gruvbox_material_palette = "mix"
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_transparent_background = 0
    end,
  },
  { "ghifarit53/tokyonight-vim" },
  {
    "navarasu/onedark.nvim",
    disable = true,
    setup = function()
      vim.g.onedark_style = "warmer"
    end,
  },
  {
    "rmehri01/onenord.nvim",
    disable = true,
    config = function()
      vim.cmd("colorscheme onenord")
    end,
  },
  {
    "Mofiqul/vscode.nvim",
    disable = true,
    config = function()
      vim.cmd("colorscheme vscode")
    end,
  },
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup {}
      vim.cmd("colorscheme github_dark")
    end,
  },
}
