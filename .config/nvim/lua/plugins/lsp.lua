local lsp = vim.lsp
local handlers = lsp.handlers

-- Borders around lsp windows
local popup_opts = { border = "single", max_width = 60 }
handlers["textDocument/hover"] = lsp.with(handlers.hover, popup_opts)
handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, popup_opts)

local lspinstall = require("lspinstall")
local function setup_lsp_servers()
  lspinstall.setup()

  local lsp_conf = require("lspconfig")
  local coq = require("coq")

  local servers = lspinstall.installed_servers()
  local manually_installed = {"pyright", "html", "vimls", "hls"}
  for _, server in ipairs(manually_installed) do
    table.insert(servers, server)
  end
  for _, server in ipairs(servers) do
    lsp_conf[server].setup(coq.lsp_ensure_capabilities())
  end
end
setup_lsp_servers()

-- Automatically install after :LspInstall <server>
lspinstall.post_install_hook = function()
  setup_lsp_servers()
  -- Triggers the autocmd that starts the server
  vim.cmd("bufdo e")
end

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false
  }
)

local map = require('../utils').map
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
map('n', 'gr', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
map('n', 'gh', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')

-- Format whole file
map('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting_sync()<cr>')

