-- Better hover window colors
local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID('NormalFloat'), 'bg')
local normal_fg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg')
vim.cmd('highlight FloatBorder guifg=' .. normal_fg .. ' guibg=' .. normal_float_bg)

local lsp = require('vim.lsp')
local handlers = lsp.handlers

-- Borders around lsp windows
local popup_opts = { border = 'single', focusable = false, max_width = 60 }
handlers['textDocument/hover'] = lsp.with(handlers.hover, popup_opts)
handlers['textDocument/signatureHelp'] = lsp.with(handlers.signature_help, popup_opts)

local lsp_conf = require('lspconfig')
local lspinstall = require('lspinstall')

local cmp_lsp, coq

local function setup_lsp(server, config)
  config = config or {}
  -- Prefer cmp over coq if both are available
  if cmp_lsp ~= nil then
    local capabilities = cmp_lsp.update_capabilities(
      lsp.protocol.make_client_capabilities()
    )
    config = vim.tbl_deep_extend('error', config, { capabilities = capabilities })
  elseif coq ~= nil then
    config = vim.tbl_deep_extend('error', config, { coq.lsp_ensure_capabilities() })
  end

  lsp_conf[server].setup(config)
end

local function setup_lsp_servers()
  lspinstall.setup()
  local servers = lspinstall.installed_servers()
  local manually_installed = {'pyright', 'html', 'vimls'}
  for _, server in ipairs(manually_installed) do
    table.insert(servers, server)
  end
  print('Available LSP servers:', vim.inspect(servers))

  if package.loaded['cmp_nvim_lsp'] then
    cmp_lsp = require('cmp_nvim_lsp')
  elseif package.loaded['coq'] then
    coq = require('coq')
  end

  for _, server in ipairs(servers) do
    if server == 'lua' then
      setup_lsp('lua', require('plugins/lsp/lua').config())
    elseif server == 'haskell' then
      setup_lsp('haskell', require('plugins/lsp/haskell').config())
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
  vim.cmd('bufdo e')
end

lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false
  }
)

local map = require('../utils').map
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
map('n', 'gr', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
map('n', 'gh', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')

-- Format visual selection
map('v', '<leader>=', '<cmd>lua vim.lsp.buf.formatting_sync()<cr>')

