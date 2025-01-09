return {
  {
    "saghen/blink.compat",
    lazy = true,
    opts = {},
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "v0.*",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      { "smjonas/cmp-jira" },
    },
    config = {
      keymap = {
        preset = "default",
        ["<C-s>"] = { "select_and_accept" },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "cmp_jira" },
        providers = {
          cmp_jira = {
            name = "cmp_jira",
            module = "blink.compat.source",
          },
        },
      },
      snippets = {
        preset = "luasnip",
      },
    },
  },
}
