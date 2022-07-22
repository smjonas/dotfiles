local map = vim.keymap.set

local opts = {
  silent = true,
}

return function(client, bufnr)
  opts.buffer = bufnr
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>zz", opts)
  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "<C-j>", vim.diagnostic.goto_prev)
  map("n", "<C-k>", vim.diagnostic.goto_next)

  vim.keymap.set("n", "<leader>rn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { expr = true })

  require("nvim-navic").attach(client, bufnr)
end
