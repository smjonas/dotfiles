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
    vim.schedule(function()
      vim.cmd("norm zz")
    end)
  end, opts)

  safe_require("lsp_signature").on_attach({
    doc_lines = 0,
    hint_enable = false,
    toggle_key = "<C-s>",
    -- floating_window = false,
    max_width = 200,
    -- hi_parameter = "DiffAdd",
  }, bufnr)

  -- safe_require("lsp-inlayhints").on_attach(client, bufnr)

  map("n", "K", vim.lsp.buf.hover, opts)
  -- map("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
  map("n", "<C-j>", vim.diagnostic.goto_prev)
  map("n", "<C-k>", vim.diagnostic.goto_next)
  map("n", "<leader>a", vim.lsp.buf.code_action, opts)

  -- safe_require("nvim-navic").attach(client, bufnr)
end
