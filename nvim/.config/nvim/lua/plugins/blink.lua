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
      { "giuxtaposition/blink-cmp-copilot" },
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
        default = { "lsp", "path", "snippets", "buffer", "cmp_jira", "copilot" },
        providers = {
          cmp_jira = {
            name = "cmp_jira",
            module = "blink.compat.source",
          },
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
      snippets = {
        preset = "luasnip",
      },
    },
  },
}
