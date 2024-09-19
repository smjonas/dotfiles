local inc_rename = {
  "smjonas/inc-rename.nvim",
  branch = "tests",
  dev = true,
  -- "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  keys = "<leader>rn",
  config = function()
    require("inc_rename").setup {
      async = true,
      hl_group = "IncSearch",
      input_buffer_type = "dressing",
      save_in_cmdline_history = false,
    }
    vim.keymap.set("n", "<leader>rn", function()
      -- Fallback to text substitution when LSP is not available
      local cur_word = vim.fn.expand("<cword>")
      if vim.tbl_isempty(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }) then
        return ":%s/" .. cur_word .. "//gc" .. ("<left>"):rep(3)
      else
        return ":IncRename " .. cur_word
      end
    end, { expr = true, desc = "Start IncRename" })
  end,
  dependencies = {
    { "stevearc/dressing.nvim", config = { input = { insert_only = false } } },
  },
}

local live_command = {
  "smjonas/live-command.nvim",
  dev = true,
  branch = "main",
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
    }
    require("live-command").setup {
      debug = true,
      commands = commands,
    }
  end,
}

local snippet_converter = {
  "smjonas/snippet-converter.nvim",
  dev = false,
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
  dev = false,
  config = function()
    require("live_tests_busted")
  end,
}

local editree = {
  "smjonas/editree.nvim",
  dev = true,
  enabled = true,
  config = function()
    require("editree").setup()
    vim.keymap.set("n", "<F1>", function()
      if vim.bo.filetype == "fern" or vim.bo.filetype == "editree" then
        vim.cmd.Editree("toggle")
      end
    end, { desc = "Toggle editree" })
  end,
  dependencies = {
    { "stevearc/oil.nvim", config = {} },
  },
}

return {
  live_command,
  inc_rename,
  snippet_converter,
  live_tests_busted,
  editree,
}
