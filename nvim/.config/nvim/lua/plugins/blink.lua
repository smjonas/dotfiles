return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v0.*",
  dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
  config = {
    keymap = {
      preset = "default",
      ["<C-s>"] = { "select_and_accept" },
    },
    completion = { accept = { auto_brackets = { enabled = true } } },
    snippets = {
      expand = function(snippet)
        require("luasnip").lsp_expand(snippet)
      end,
      active = function(filter)
        if filter and filter.direction then
          return require("luasnip").jumpable(filter.direction)
        end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction)
        require("luasnip").jump(direction)
      end,
    },
  },
}
