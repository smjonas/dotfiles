return {
  -- Current color scheme
  {
    "folke/tokyonight.nvim",
    config = function()
      pcall(vim.cmd, "colorscheme tokyonight-moon")
    end,
  },
  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      vim.cmd("autocmd User VimtexEventInitPost VimtexCompile")
    end,
  },
  -- Misc
  { "alvan/vim-closetag", ft = { "html", "php" } },
  "arp242/undofile_warn.vim",
  "tpope/vim-repeat",
  "rmagatti/auto-session",
  { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
}
