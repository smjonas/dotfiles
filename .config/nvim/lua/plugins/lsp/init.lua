local map = vim.keymap.set
local lsp = require("vim.lsp")

-- We don't need the default Ctrl-F, so make the mapping global
map("n", "<C-f>", lsp.buf.formatting_sync, { silent = true })
-- Note: not all LSP servers support range formatting
map("v", "<C-f>", lsp.buf.range_formatting, { silent = true })

local on_attach = require("plugins.lsp.on_attach")

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
        opts = vim.tbl_deep_extend("force", opts, require("plugins.lsp." .. customized_server))
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

vim.diagnostic.config {
  virtual_text = false,
}

-- Borders around lsp windows
local popup_opts = { border = "single", focusable = false, max_width = 60 }
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
