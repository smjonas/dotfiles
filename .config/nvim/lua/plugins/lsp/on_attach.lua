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

  require("lsp_signature").on_attach({
    doc_lines = 0,
    hint_enable = false,
    toggle_key = "<C-s>",
    -- floating_window = false,
    max_width = 200,
    -- hi_parameter = "DiffAdd",
  }, bufnr)
  -- map("i", "<C-s>", vim.lsp.buf.signature_help, opts)

  -- map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
  map("n", "<C-j>", vim.diagnostic.goto_prev)
  map("n", "<C-k>", vim.diagnostic.goto_next)

  vim.keymap.set("n", "<leader>rn", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
  end, { expr = true })

  require("nvim-navic").attach(client, bufnr)
end
