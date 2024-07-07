return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = { "markdown", "vimwiki", "text" },
    config = function()
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_filetypes = { "markdown", "vimwiki", "text" }
      vim.keymap.set("n", "<leader>m", "<Plug>MarkdownPreviewToggle")
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
