return {
    "smjonas/snippet-converter.nvim",
    dev = true,
    branch = "yasnippet",
    config = function()
      local snippet_converter = require("snippet_converter")
      local ultisnips_to_luasnip = {
        name = "ultisnips_to_luasnip",
        sources = {
          ultisnips = {
            "~/.config/nvim/after/my_snippets/ultisnips",
          },
        },
        output = {
          vscode_luasnip = {
            "~/.config/nvim/after/my_snippets/luasnip",
          },
        },
      }
      local yasnippet = {
        name = "yasnippet",
        sources = {
          yasnippet = {
            "~/Desktop/yasnippets",
          },
        },
        output = {
          vscode_luasnip = {
            "~/Desktop/yasnippets_output",
          },
        },
      }
      local extends_test = {
        name = "extends_test",
        sources = {
          ultisnips = {
            "~/Desktop/ultisnips/",
          },
        },
        output = {
          vscode = {
            "~/Desktop/ultisnips/output",
          },
        },
      }
      snippet_converter.setup {
        -- templates = { ultisnips_to_luasnip, friendly_snippets },
        templates = { yasnippet, extends_test },
      }
    end,
  }
