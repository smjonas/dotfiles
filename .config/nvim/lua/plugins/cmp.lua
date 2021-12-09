local function has_any_words_before()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
  if snippet_engine == "luasnip"
    and luasnip.choice_active()
    and luasnip.expand_or_locally_jumpable() then

    luasnip.change_choice(1)
  elseif cmp.visible() then
    cmp.select_next_item()
  else fallback() end
end

local function ctrl_p(snippet_engine, fallback)
  if snippet_engine == "luasnip"
    and luasnip.choice_active()
    and luasnip.expand_or_locally_jumpable() then

    luasnip.change_choice(-1)
  elseif cmp.visible() then
    cmp.select_prev_item()
  else fallback() end
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
    { name = "path" },
    { name = cur_snippet_engine, priority = 10 },
    { name = "buffer", keyword_length = 3 },
  },
  experimental = {
    ghost_text = true
  },
  mapping = {
    -- mostly keep defaults except use <C-f> instead <C-y>
    -- and overload tab keys for snippet plugins
    ["<C-f>"] = cmp.mapping(cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }, { "i", "c" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      tab_for(cur_snippet_engine, fallback)
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      shift_tab_for(cur_snippet_engine, fallback)
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete()),
    ["<C-n>"] = cmp.mapping(function(fallback)
      ctrl_n(cur_snippet_engine, fallback)
    end),
    ["<C-p>"] = cmp.mapping(function(fallback)
      ctrl_p(cur_snippet_engine, fallback)
    end)
  },
  sorting = {
    comparators = {
      function(...) return require("cmp_buffer"):compare_locality(...) end,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require("cmp-under-comparator").under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  }
}


