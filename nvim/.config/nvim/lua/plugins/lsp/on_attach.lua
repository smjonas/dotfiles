local M = {}

local map = vim.keymap.set

local opts = {
  silent = true,
}

M.go_to_definition = function()
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
end

M.attach = function(client, bufnr)
  if client.name == "ruff" then
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end

  opts.buffer = bufnr
  map("n", "gd", M.go_to_definition, opts)

  safe_require("lsp_signature").on_attach({
    doc_lines = 0,
    hint_enable = false,
    toggle_key = "<C-s>",
    -- floating_window = false,
    max_width = 200,
    -- hi_parameter = "DiffAdd",
  }, bufnr)

  local ok, delimited = pcall(require, "delimited")
  if not ok then
    vim.notify(
      "delimited.nvim is not installed, falling back to vim.diagnostic",
      vim.log.levels.WARN
    )
    map("n", "<C-j>", vim.diagnostic.goto_prev)
    map("n", "<C-k>", vim.diagnostic.goto_next)
  else
    map("n", "<C-j>", delimited.goto_prev)
    map("n", "<C-k>", delimited.goto_next)
  end

  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "<leader>a", vim.lsp.buf.code_action, opts)

  -- safe_require("nvim-navic").attach(client, bufnr)
end

return M
