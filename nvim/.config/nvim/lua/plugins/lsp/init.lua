local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
    { "mizlan/delimited.nvim", opts = {} },
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      config = function()
        local ensure_installed = { "lua_ls", "pylsp" }
        require("mason").setup()
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup()

        vim.api.nvim_create_user_command("MasonInstallAll", function()
          vim.cmd("MasonInstall " .. table.concat(ensure_installed, " "))
        end, {})
      end,
      dependencies = { "williamboman/mason-lspconfig.nvim" },
    },
  },
}

M.config = function()
  local map = vim.keymap.set

  -- We don't need the default Ctrl-F, so make the mapping global
  map("n", "<C-f>", function()
    require("conform").format { lsp_format = "last" }
  end, { silent = true })

  -- Contain keymappings to set when server attached
  local on_attach = require("plugins.lsp.on_attach").attach
  local setup_lsp_servers = function()
    local lsp_config = require("lspconfig")
    local server_list = { "rust_analyzer", "ruff" }
    local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
    if ok then
      server_list = vim.list_extend(server_list, mason_lspconfig.get_installed_servers())
    else
      vim.notify(
        "mason-lspconfig is not installed: could not get installed servers",
        vim.log.levels.ERROR
      )
    end

    local capabilities = require("blink-cmp").get_lsp_capabilities()
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

  local hint = vim.diagnostic.severity.HINT
  local info = vim.diagnostic.severity.INFO
  local warn = vim.diagnostic.severity.WARN
  local error = vim.diagnostic.severity.ERROR
  vim.diagnostic.config {
    virtual_text = false,
    signs = {
      text = {
        [hint] = "󰌵",
        [info] = "󰋼",
        [warn] = "",
        [error] = "󰅙",
      },
      linehl = {
        [hint] = "DiagnosticHint",
        [info] = "DiagnosticInfo",
        [warn] = "DiagnosticWarn",
        [error] = "DiagnosticError",
      },
    },
  }

  -- Borders around LSP windows
  local lsp = vim.lsp
  lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
    border = "rounded",
  })
end

return M
