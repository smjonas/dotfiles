local cmp = require('cmp')

local has_any_words_before = function()
  if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local press = function(key)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), 'n', true)
end

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn['UltiSnips#Anon'](args.body)
    end,
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    -- { name = 'vsnip' },
    -- { name = 'luasnip' },
    { name = 'path' },
    { name = 'ultisnips' },
    { name = 'buffer', keyword_length = 4 },
  },
  experimental = {
      ghost_text = true
  },
  mapping = {
    ['<C-f>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    -- Boilerplate code for compatibility with UltiSnips (see cmp-nvim-ultisnips plugin)
    -- <TAB> and <S-TAB>: cycle forward and backward through autocompletion items
    -- <TAB> and <S-TAB>: cycle forward and backward through snippets tabstops and placeholders
    -- <TAB> to expand snippet when no completion item selected
    -- <C-space> to expand the selected snippet from completion menu
    ['<C-Space>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if vim.fn['UltiSnips#CanExpandSnippet']() == 1 then
          return press('<C-R>=UltiSnips#ExpandSnippet()<CR>')
        end

        cmp.select_next_item()
      elseif has_any_words_before() then
        press('<Space>')
      else
        fallback()
      end
    end, {
      'i', 's'
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.get_selected_entry() == nil and vim.fn['UltiSnips#CanExpandSnippet']() == 1 then
        press('<C-R>=UltiSnips#ExpandSnippet()<CR>')
      elseif vim.fn['UltiSnips#CanJumpForwards']() == 1 then
        press('<ESC>:call UltiSnips#JumpForwards()<CR>')
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif has_any_words_before() then
        press('<Tab>')
      else
        fallback()
      end
    end, {
      'i', 's'
    }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if vim.fn['UltiSnips#CanJumpBackwards']() == 1 then
        press('<ESC>:call UltiSnips#JumpBackwards()<CR>')
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, {
      'i', 's'
    })
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      require 'cmp-under-comparator'.under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  }
}

-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- cmp.setup.cmdline(':', {
--   -- only use suggestions from cmdline if none are available for path source
--   sources = cmp.config.sources(
--     {
--         { name = 'path' }
--     },
--     {
--         { name = 'cmdline' }
--     }
--   )
-- })
