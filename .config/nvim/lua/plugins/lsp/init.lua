local lsp = require("vim.lsp")

local function setup_lsp_servers()
  local lsp_installer = require("nvim-lsp-installer")
  lsp_installer.on_server_ready(function(server)
    local opts = {
      single_file_support = true,
    }
    local customized_servers = { "pyright", "sumneko_lua" }
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

-- Better hover window colors
local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=NONE") --.. normal_float_bg)

vim.diagnostic.config({
  virtual_text = false,
})

-- Borders around lsp windows
local popup_opts = { border = "single", focusable = false, max_width = 60 }
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)

local map = require("../utils").map
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
map("n", "<C-j>", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
map("n", "<leader>gd", "<cmd>lua vim.diagnostic.open_float()<cr>")
map("n", "<C-k>", "<cmd>lua vim.diagnostic.goto_next()<cr>")

-- Formatting; not all LSP servers support range formatting
map("n", "<C-f>", "<cmd>lua vim.lsp.buf.formatting_sync()<cr>")
map("v", "<C-f>", "<cmd>lua vim.lsp.buf.range_formatting()<cr>")
