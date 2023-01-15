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
  {
    "luukvbaal/statuscol.nvim",
    config = function()
      require("statuscol").setup { setopt = true }
    end,
  },
  { "alvan/vim-closetag", ft = { "html", "php" } },
  "arp242/undofile_warn.vim",
  "tpope/vim-repeat",
  "rmagatti/auto-session",
  "inkarkat/vim-ReplaceWithRegister",
  { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
}
