local M = {
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "folke/neodev.nvim",
    "ray-x/lsp_signature.nvim",
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
      dependencies = { "williamboman/mason-lspconfig.nvim" },
    },
  },
}

M.config = function()
  local map = vim.keymap.set

  -- We don't need the default Ctrl-F, so make the mapping global
  map("n", "<C-f>", vim.lsp.buf.format, { silent = true })
  -- Note: not all LSP servers support range formatting
  -- map("v", "<C-f>", vim.lsp.buf.range_formatting, { silent = true })

  local lsp = require("lsp-zero")
  local setup_lsp_servers = function()
    local ok, _ = pcall(require, "mason-lspconfig")
    if not ok then
      vim.notify("Mason was not found: no LSP servers set up", vim.log.levels.ERROR)
      return
    end

    lsp.preset("recommended")
    lsp.ensure_installed { "pylsp", "gopls" }

    local opts = {
      -- Contains keymappings to set when server is attached
      on_attach = require("plugins.lsp.on_attach"),
      single_file_support = true,
    }
    -- Set a default configuration
    lsp.set_server_config(opts)

    local customized_servers = { "sumneko_lua", "pylsp" }
    for _, server in ipairs(customized_servers) do
      local custom_opts = vim.tbl_deep_extend("force", {}, require("plugins.lsp." .. server))
      lsp.configure(server, custom_opts)
    end
    lsp.setup { manage_nvim_cmp = false }
  end
  setup_lsp_servers()
  lsp.set_sign_icons { info = "", hint = "", warn = "", error = "" }

  -- Better hover window colors
  local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
  local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
  -- vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=NONE") --.. normal_float_bg)

  vim.diagnostic.config {
    virtual_text = false,
  }

  -- Borders around lsp windows
  -- local popup_opts = { border = "single", focusable = false, max_width = 60 }
  -- lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
  -- lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
end

return M
