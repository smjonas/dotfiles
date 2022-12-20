return {
  "L3MON4D3/LuaSnip",
  -- after = "nvim-cmp",
  config = function()
    require("luasnip.loaders.from_vscode").load { paths = { "./after/my_snippets/luasnip" } }
  end,
}
