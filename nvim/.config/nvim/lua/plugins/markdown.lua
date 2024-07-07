return {
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   build = "cd app && npm install",
  --   ft = { "markdown", "vimwiki", "text" },
  --   config = function()
  --     vim.g.mkdp_auto_close = 0
  --     vim.g.mkdp_filetypes = { "markdown", "vimwiki", "text" }
  --     vim.keymap.set("n", "<leader>m", "<Plug>MarkdownPreviewToggle")
  --   end,
  -- },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.keymap.set("n", "<leader>m", require("peek").open, {})
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
