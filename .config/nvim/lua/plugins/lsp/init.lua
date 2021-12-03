
local lsp = require("vim.lsp")

local function setup_lsp_servers()
  local lsp_installer = require("nvim-lsp-installer")
  lsp_installer.on_server_ready(function(server)
    local opts = {}
    local customized_servers = { "hls", "pyright", "sumneko_lua" }
    for _, customized_server in pairs(customized_servers) do
      if server.name == customized_server then
        opts = require("plugins/lsp/" .. customized_server)
      end
    end

    if vim.g["completion_plugin"] == "cmp" then
      local capabilities = require("cmp_nvim_lsp").update_capabilities(
        lsp.protocol.make_client_capabilities()
      )
      opts = vim.tbl_deep_extend("error", opts, { capabilities = capabilities })
    elseif vim.g["completion_plugin"] == "coq" then
      opts = vim.tbl_deep_extend("error", opts, { require("coq").lsp_ensure_capabilities() })
    end
    server:setup(opts)
  end)
end

setup_lsp_servers()

---

local handlers = lsp.handlers

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
  lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false
  }
)

-- Better hover window colors
local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=" .. normal_float_bg)

-- Borders around lsp windows
local popup_opts = { border = "single", focusable = false, max_width = 60 }
handlers["textDocument/hover"] = lsp.with(handlers.hover, popup_opts)
handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, popup_opts)

local map = require("../utils").map
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
map("n", "gr", "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>")
map("n", "gh", "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>")

-- Format visual selection
map("v", "<leader>=", "<cmd>lua vim.lsp.buf.formatting_sync()<cr>")

