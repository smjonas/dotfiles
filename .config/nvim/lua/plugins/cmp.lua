local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "saadparwaiz1/cmp_luasnip",
    {
      "zbirenbaum/copilot-cmp",
      config = function()
        require("copilot_cmp").setup()
      end,
    },
    "vE5li/cmp-buffer",
    "hrsh7th/cmp-path",
    "max397574/cmp-greek",
  },
}

M.config = function()
  local cmp = require("cmp")
  local compare = cmp.config.compare

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

  local under_comparator = function(entry1, entry2)
    local _, entry1_under = entry1.completion_item.label:find("^_+")
    local _, entry2_under = entry2.completion_item.label:find("^_+")
    entry1_under = entry1_under or 0
    entry2_under = entry2_under or 0
    if entry1_under > entry2_under then
      return false
    elseif entry1_under < entry2_under then
      return true
    end
  end

  local function has_any_words_before()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
      return false
    end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  cmp.setup {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    sources = {
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "path", priority = 20 },
      { name = "greek" },
      { name = "luasnip", priority = 10, keyword_length = 1 },
      { name = "buffer", option = { keyword_pattern = [[\k\+]] }, keyword_length = 1 },
    },
    enabled = function()
      local in_prompt = vim.api.nvim_buf_get_option(0, "buftype") == "prompt"
      if in_prompt or vim.bo.filetype == "TelescopePrompt" then
        return false
      end
      local context = require("cmp.config.context")
      return not (context.in_treesitter_capture("comment") or context.in_syntax_group("Comment"))
    end,
    experimental = {
      ghost_text = {},
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
      -- mostly keep defaults except use <C-f> instead <C-y>
      -- and overload tab keys for snippet plugins
      ["<C-f>"] = cmp.mapping(
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
    },
    sorting = {
      comparators = {
        function(...)
          return require("cmp_buffer"):compare_locality(...)
        end,
        compare.locality,
        compare.recently_used,
        -- compare.exact,
        compare.score,
        under_comparator,
        compare.kind,
        compare.sort_text,
        compare.length,
        compare.order,
      },
    },
    formatting = {
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
