local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "saadparwaiz1/cmp_luasnip",
    {
      "zbirenbaum/copilot-cmp",
      enabled = false,
      config = function()
        require("copilot_cmp").setup()
      end,
    },
    {
      "supermaven-inc/supermaven-nvim",
      config = function()
        require("supermaven-nvim").setup {}
      end,
    },
    "vE5li/cmp-buffer",
    "hrsh7th/cmp-path",
  },
}

M.config = function()
  local cmp = require("cmp")

  local ok, luasnip = pcall(require, "luasnip")
  if not ok then
    return
  end

  local lsp_icons = {
    Class = "󰠱",
    Color = "󰏘",
    Constant = "󰐀",
    Constructor = "⌘",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "󰜢",
    File = "󰈙",
    Folder = "",
    Function = "󰊕",
    Interface = "",
    Keyword = "󰔌",
    Method = "󰆧",
    Module = "󰏓",
    Operator = "󰆕",
    Property = "󰜢",
    Reference = "󰈇",
    Snippet = "󰅱",
    Struct = "󰙅",
    Text = "",
    TypeParameter = "",
    Unit = "󰑭",
    Value = "󰎠",
    Variable = "󰈜",
  }

  local function has_any_words_before()
    if vim.api.nvim_get_option_value("buftype", {}) == "prompt" then
      return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  cmp.setup.filetype({ "gitcommit" }, {
    sources = {
      { name = "cmp_jira" },
      { name = "cmp-buffer" },
    },
  })

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "supermaven" },
      { name = "luasnip", max_item_count = 10 },
      { name = "path" },
    }, {
      { name = "buffer" },
    }),
    enabled = function()
      local in_prompt = vim.api.nvim_get_option_value("buftype", {}) == "prompt"
      if in_prompt or vim.bo.filetype == "TelescopePrompt" then
        return false
      end
      return true
    end,
    experimental = {
      ghost_text = {
        hl_group = "CmpGhostText",
      },
    },
    completion = {
      border = "rounded",
      scrollbar = "║",
      -- See https://github.com/hrsh7th/nvim-cmp/issues/808
      keyword_pattern = [[\k\+]],
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = {
      ["<C-s>"] = cmp.mapping(
        cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        { "i", "s" }
      ),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif has_any_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, {
        "i",
        "s", --[[ "c" (to enable the mapping in command mode) ]]
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s", --[[ "c" (to enable the mapping in command mode) ]]
      }),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete()),
      ["<C-n>"] = cmp.mapping(function(fallback)
        if luasnip.choice_active() and luasnip.expand_or_locally_jumpable() then
          luasnip.change_choice(1)
        elseif cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-p>"] = cmp.mapping(function(fallback)
        if luasnip.choice_active() and luasnip.expand_or_locally_jumpable() then
          luasnip.change_choice(-1)
        elseif cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      [KB["cmp.previous"]] = cmp.mapping(function(fallback)
        if luasnip.choice_active() and luasnip.expand_or_locally_jumpable() then
          luasnip.change_choice(-1)
        elseif cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    formatting = {
      dependencies = { "williamboman/mason-lspconfig.nvim" },

      fields = { "kind", "abbr", "menu" },
      format = function(_, vim_item)
        vim_item.menu = vim_item.kind
        vim_item.kind = lsp_icons[vim_item.kind]
        return vim_item
      end,
    },
  }
end

return M
