local map = vim.keymap.set

local opts = {
  silent = true,
}

return function(client, bufnr)
  opts.buffer = bufnr
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>zz", opts)
  -- Always use inc-rename.nvim
  vim.keymap.set("n", "<leader>rn", ":IncRename ")
  map("n", "K", vim.lsp.buf.hover, opts)
  -- Show buffer diagnostics in a floating menu
  map("n", "<leader>gd", "<cmd>lua vim.diagnostic.open_float({scope = 'buffer'})<cr>", opts)
  map("n", "<C-j>", vim.diagnostic.goto_prev, opts)
  map("n", "<C-k>", vim.diagnostic.goto_next, opts)

  require("nvim-navic").attach(client, bufnr)
end
