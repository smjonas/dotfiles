local duplicate = {
  "smjonas/duplicate.nvim",
  dev = true,
  config = function()
    require("duplicate").setup()
  end,
}

local inc_rename = {
  "smjonas/inc-rename.nvim",
  branch = "preview",
  -- "smjonas/inc-rename.nvim",
  config = function()
    require("inc_rename").setup {
      async = true,
      hl_group = "IncSearch",
    }
  end,
}

local live_command = {
  "smjonas/live-command.nvim",
  dependencies = { "tpope/vim-abolish" },
  -- dev = true,
  -- branch = "inline_highlights",
  -- "smjonas/live-command.nvim",
  config = function()
    local commands = {
      Norm = { cmd = "norm" },
      G = { cmd = "g" },
      D = { cmd = "d" },
      Reg = {
        cmd = "norm",
        args = function(opts)
          return (opts.count == -1 and "" or opts.count) .. "@" .. opts.args
        end,
        range = "",
      },
      LSubvert = { cmd = "Subvert" },
      S = { cmd = "substitute" },
    }
    require("live-command").setup {
      debug = true,
      commands = commands,
    }
  end,
}

local snippet_converter = {
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

local live_tests_busted = {
  "smjonas/live-tests-busted.nvim",
  config = function()
    require("live_tests_busted")
  end,
}

return { duplicate, live_command, inc_rename, snippet_converter, live_tests_busted }
