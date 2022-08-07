local map = vim.keymap.set

local opts = {
  silent = true,
}

return function(client, bufnr)
  opts.buffer = bufnr
  map("n", "gd", function()
    vim.lsp.buf.definition {
      on_list = function(items)
        -- Do not open the quickfix list (very annoying with sumneko lua),
        -- but simply jump to the first item
        vim.fn.setqflist({}, "r", items)
        vim.cmd("cfirst")
      end,
    }
    vim.cmd("norm zz")
  end, opts)

  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "<C-j>", vim.diagnostic.goto_prev)
  map("n", "<C-k>", vim.diagnostic.goto_next)

  vim.keymap.set("n", "<leader>rn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { expr = true })

  require("nvim-navic").attach(client, bufnr)
end
