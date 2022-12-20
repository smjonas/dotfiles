return {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = { "markdown", "text" },
    config = function()
      vim.g["mkdp_auto_close"] = 0
      vim.g["mkdp_filetypes"] = { "markdown", "text" }
      map("n", "<leader>m", "<Plug>MarkdownPreviewToggle", { noremap = false })
    end,
  }
