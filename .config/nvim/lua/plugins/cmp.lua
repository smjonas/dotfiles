require("cmp").setup {
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
    sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      -- { name = 'luasnip' },
      { name = 'ultisnips' },
      { name = 'buffer' }
    }
  }
}
