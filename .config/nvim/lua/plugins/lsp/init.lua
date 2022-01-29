local keymap = vim.keymap
local lsp = require("vim.lsp")

local on_attach = function(_, bufnr)
  local opts = {
    silent = true,
    buffer = bufnr,
  }
  keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>zz", opts)
  keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
  keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
  -- Show buffer diagnostics in a floating menu
  keymap.set("n", "<leader>gd", "<cmd>lua vim.diagnostic.open_float({scope = 'buffer'})<cr>", opts)
  keymap.set("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
  keymap.set("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)

  -- Note: not all LSP servers support range formatting
  keymap.set("n", "<C-f>", "<cmd>lua vim.lsp.buf.formatting_sync()<cr>", opts)
  keymap.set("v", "<C-f>", "<cmd>lua vim.lsp.buf.range_formatting()<cr>", opts)
end

local setup_lsp_servers = function()
  local lsp_installer = require("nvim-lsp-installer")
  local capabilities = require("cmp_nvim_lsp").update_capabilities(
    lsp.protocol.make_client_capabilities()
  )
  lsp_installer.on_server_ready(function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
      single_file_support = true,
    }
    local customized_servers = { "sumneko_lua" }
    for _, customized_server in pairs(customized_servers) do
      if server.name == customized_server then
        opts = vim.tbl_deep_extend("error", opts, require("plugins/lsp/" .. customized_server))
      end
    end
    server:setup(opts)
  end)
end

setup_lsp_servers()

-- Better hover window colors
local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
-- vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=NONE") --.. normal_float_bg)

vim.diagnostic.config({
  virtual_text = false,
})

-- Borders around lsp windows
local popup_opts = { border = "single", focusable = false, max_width = 60 }
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
