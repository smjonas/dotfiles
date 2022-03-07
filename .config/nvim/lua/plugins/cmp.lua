local function has_any_words_before()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")
local cur_snippet_engine = vim.g["snippet_engine"]

local luasnip
if cur_snippet_engine == "luasnip" then
  luasnip = require("luasnip")
end

local function expand_for(snippet_engine, args)
  if snippet_engine == "luasnip" then
    luasnip.lsp_expand(args.body)
  elseif snippet_engine == "ultisnips" then
    vim.fn["UltiSnips#Anon"](args.body)
  end
end

local function ctrl_n(snippet_engine, fallback)
  if
    snippet_engine == "luasnip"
    and luasnip.choice_active()
    and luasnip.expand_or_locally_jumpable()
  then
    luasnip.change_choice(1)
  elseif cmp.visible() then
    cmp.select_next_item()
  else
    fallback()
  end
end

local function ctrl_p(snippet_engine, fallback)
  if
    snippet_engine == "luasnip"
    and luasnip.choice_active()
    and luasnip.expand_or_locally_jumpable()
  then
    luasnip.change_choice(-1)
  elseif cmp.visible() then
    cmp.select_prev_item()
  else
    fallback()
  end
end

local function tab_for(snippet_engine, fallback)
  if snippet_engine == "luasnip" then
    if luasnip.expand_or_locally_jumpable() then
      luasnip.expand_or_jump()
    elseif has_any_words_before() then
      cmp.complete()
    else
      fallback()
    end
  elseif snippet_engine == "ultisnips" then
    require("cmp_nvim_ultisnips.mappings").expand_or_jump_forwards(fallback)
  end
end

local function shift_tab_for(snippet_engine, fallback)
  if snippet_engine == "luasnip" then
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  elseif snippet_engine == "ultisnips" then
    require("cmp_nvim_ultisnips.mappings").jump_backwards(fallback)
  end
end

local lsp_icons = {
  Class = " ",
  Color = " ",
  Constant = " ",
  Constructor = " ",
  Enum = "了 ",
  EnumMember = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = " ",
  Interface = "ﰮ ",
  Keyword = " ",
  Method = "ƒ ",
  Module = " ",
  Property = " ",
  Snippet = "﬌ ",
  Struct = " ",
  Text = " ",
  Unit = " ",
  Value = " ",
  Variable = " ",
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

cmp.setup {
  snippet = {
    expand = function(args)
      expand_for(cur_snippet_engine, args)
    end,
  },
  sources = {
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path", priority = 20 },
    { name = cur_snippet_engine, priority = 10 },
    {
      name = "buffer",
      option = {
        keyword_pattern = [[\k\+]],
      },
      keyword_length = 1,
    },
  },
  enabled = function()
    local in_prompt = vim.api.nvim_buf_get_option(0, "buftype") == "prompt"
    if in_prompt then
      return false
    end
    local context = require("cmp.config.context")
    return not (context.in_treesitter_capture("comment") or context.in_syntax_group("Comment"))
  end,
  experimental = {
    ghost_text = true,
  },
  completion = {
    border = "rounded",
    scrollbar = "║",
    -- See https://github.com/hrsh7th/nvim-cmp/issues/808
    keyword_pattern = [[\k\+]],
  },
  documentation = {
    border = nil,
    scrollbar = "",
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
      tab_for(cur_snippet_engine, fallback)
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      shift_tab_for(cur_snippet_engine, fallback)
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete()),
    ["<C-n>"] = cmp.mapping(function(fallback)
      ctrl_n(cur_snippet_engine, fallback)
    end, { "i", "s" }),
    ["<C-p>"] = cmp.mapping(function(fallback)
      ctrl_p(cur_snippet_engine, fallback)
    end, { "i", "s" }),
  },
  sorting = {
    comparators = {
      function(...)
        return require("cmp_buffer"):compare_locality(...)
      end,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      under_comparator,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = string.format("%s %s", lsp_icons[vim_item.kind], vim_item.kind)
      return vim_item
    end,
  },
}
