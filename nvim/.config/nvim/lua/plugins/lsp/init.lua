local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "folke/neodev.nvim",
    "ray-x/lsp_signature.nvim",
    -- {
    --   "lvimuser/lsp-inlayhints.nvim",
    --   enable = false,
    --   branch = "anticonceal",
    --   config = function()
    --     require("lsp-inlayhints").setup {}
    --     -- Same as CursorColumn
    --     vim.cmd("highlight LspInlayHint guibg=#2f334d")
    --   end,
    -- },
  },
}

M.config = function()
  local map = vim.keymap.set

  -- We don't need the default Ctrl-F, so make the mapping global
  map("n", "<C-f>", require("conform").format, { silent = true })

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
  local capabilities = update_capabilities(vim.lsp.protocol.make_client_capabilities())

  local setup_lsp_servers = function()
    local ok, mason = pcall(require, "mason-lspconfig")
    if not ok then
      vim.notify("Mason was not found: no LSP servers set up", vim.log.levels.ERROR)
      return
    end
    mason.setup()

    local lsp_config = require("lspconfig")
    local server_list = { "rust_analyzer" }
    server_list = vim.list_extend(server_list, mason.get_installed_servers())

    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
      single_file_support = true,
    }
    for _, server in ipairs(server_list) do
      local customized_servers = { "lua_ls", "pylsp" }
      if vim.tbl_contains(customized_servers, server) then
        opts = vim.tbl_deep_extend("force", {}, require("plugins.lsp." .. server))
      end
      lsp_config[server].setup(opts)
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

  local diagnostic_symbols = {
    Error = "󰅙",
    Information = { "󰋼", "DiagnosticSignInfo" },
    Hint = "󰌵",
    Info = "󰋼",
    Warn = "",
  }

  for prefix, icon in pairs(diagnostic_symbols) do
    local is_table = type(icon) == "table"
    local hl = is_table and icon[2] or "DiagnosticSign" .. prefix
    vim.fn.sign_define("DiagnosticSign" .. prefix, {
      text = is_table and icon[1] or icon,
      texthl = hl,
      numhl = "Comment",
    })
  end

  -- Borders around lsp windows
  -- local popup_opts = { border = "single", focusable = false, max_width = 60 }
  -- lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)
  -- lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
end

return M
