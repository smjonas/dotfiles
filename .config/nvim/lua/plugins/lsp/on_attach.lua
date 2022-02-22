local map = vim.keymap.set

local opts = {
  silent = true,
}

return function(_, bufnr)
  opts.buffer = bufnr
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>zz", opts)
  map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
  -- Show buffer diagnostics in a floating menu
  map("n", "<leader>gd", "<cmd>lua vim.diagnostic.open_float({scope = 'buffer'})<cr>", opts)
  map("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
  map("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
end
