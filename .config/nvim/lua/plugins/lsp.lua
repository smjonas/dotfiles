local lsp = vim.lsp
local handlers = lsp.handlers

-- Borders around lsp windows
local popup_opts = { border = "single", max_width = 60 }
handlers["textDocument/hover"] = lsp.with(handlers.hover, popup_opts)
handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, popup_opts)

local lsp_conf = require("lspconfig")
local lspinstall = require("lspinstall")

local cmp_lsp, coq

local function setup_lsp(server, settings)
  -- Prefer cmp over coq if both are available
  if cmp_lsp ~= nil then
    local capabilities = cmp_lsp.update_capabilities(
      lsp.protocol.make_client_capabilities()
    )
    lsp_conf[server].setup {
      capabilities = capabilities, settings = settings
    }
  elseif coq ~= nil then
    lsp_conf[server].setup {
      capabilities = coq.lsp_ensure_capabilities(), settings = settings
    }
  end
end

local function setup_sumneko_lsp()
  local settings = {
    Lua = {
      diagnostics = {
        -- Fix global vim is undefined
        globals = { 'vim' }
      },
      telemetry = {
        enable = false
      }
    }
  }
  setup_lsp("lua", settings)
end

local function setup_lsp_servers()
  lspinstall.setup()
  local servers = lspinstall.installed_servers()
  local manually_installed = {"pyright", "html", "vimls", "hls"}
  for _, server in ipairs(manually_installed) do
    table.insert(servers, server)
  end

  if package.loaded["cmp_nvim_lsp"] then
    cmp_lsp = require("cmp_nvim_lsp")
  elseif package.loaded["coq"] then
    coq = require("coq")
  end

  for _, server in ipairs(servers) do
    if server == 'lua' then
      setup_sumneko_lsp()
    else
      setup_lsp(server)
    end
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
map('n', 'ge', '<cmd>lua vim.lsp.buf.code_action()<cr>')

-- Format visual selection
map('v', '<leader>=', '<cmd>lua vim.lsp.buf.formatting_sync()<cr>')

