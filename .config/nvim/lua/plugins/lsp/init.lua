local map = vim.keymap.set
local lsp = require("vim.lsp")

-- We don't need the default Ctrl-F, so make the mapping global
map("n", "<C-f>", lsp.buf.format, { silent = true })
-- Note: not all LSP servers support range formatting
map("v", "<C-f>", lsp.buf.range_formatting, { silent = true })

-- Modified from hrsh7th/cmp-nvim-lsp/
-- This avoids a dependency of this module on cmp_nvim_lsp.
local update_capabilities = function(capabilities)
  local completionItem = capabilities.textDocument.completion.completionItem
  completionItem.snippetSupport = true
  completionItem.preselectSupport = true
  completionItem.insertReplaceSupport = true
  completionItem.labelDetailsSupport = true
  completionItem.deprecatedSupport = true
  completionItem.commitCharactersSupport = true
  completionItem.tagSupport = { valueSet = { 1 } }
  completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }
  return capabilities
end

-- Contain keymappings to set when server attached
local on_attach = require("plugins.lsp.on_attach")
local capabilities = update_capabilities(lsp.protocol.make_client_capabilities())

local setup_lsp_servers = function()
  local lsp_installer = require("nvim-lsp-installer")
  lsp_installer.setup {
    ensure_installed = { "sumneko_lua", "pylsp" },
  }
  local lsp_config = require("lspconfig")

  for _, server in ipairs(lsp_installer.get_installed_servers()) do
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
      single_file_support = true,
    }
    local customized_servers = { "sumneko_lua", "pylsp" }
    if vim.tbl_contains(customized_servers, server.name) then
      opts = vim.tbl_deep_extend("force", opts, require("plugins.lsp." .. server.name))
    end
    -- print(vim.inspect(lsp_config[server.name], server.name))
    lsp_config[server.name].setup(opts)
  end
end

setup_lsp_servers()

-- Better hover window colors
local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
-- vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=NONE") --.. normal_float_bg)

vim.diagnostic.config {
  virtual_text = false,
}

-- Borders around lsp windows
local popup_opts = { border = "single", focusable = false, max_width = 60 }
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
