return {
  -- Current color scheme
  {
    "folke/tokyonight.nvim",
    config = function()
      pcall(vim.cmd, "colorscheme tokyonight-moon")
    end,
  },
  -- Misc
  { "alvan/vim-closetag", ft = { "html", "php" } },
  "arp242/undofile_warn.vim",
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup {
        i = {
          i = {
            j = "<Esc>",
          },
        },
      }
    end,
  },
  "tpope/vim-repeat",
  "rmagatti/auto-session",
  "inkarkat/vim-ReplaceWithRegister",
  { "Julian/vim-textobj-variable-segment", dependencies = "kana/vim-textobj-user" },
  { "kana/vim-textobj-entire", dependencies = "kana/vim-textobj-user" },
}
