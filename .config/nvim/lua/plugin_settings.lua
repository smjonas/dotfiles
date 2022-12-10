return {
  ["packer.nvim"] = {
    config = function()
      map("n", "<leader>c", "<cmd>PackerClean<cr>")
      map("n", "<leader>u", "<cmd>PackerSync<cr>")
      map("n", "<leader>i", "<cmd>PackerInstall<cr>")
    end,
  },
  ["nvim-surround"] = {
    -- disable = true,
    config = function()
      require("plugins.nvim-surround")
    end,
  },
  ["live-command.nvim"] = {
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
      }
      require("live-command").setup {
        debug = true,
        defaults = {
          --   -- hl_groups = { deletion = false },
          --   enable_highlighting = true,
          --   -- interline_highlighting = false,
          -- },
        },
        commands = commands,
      }
    end,
  },
  ["live-tests-busted.nvim"] = {
    config = function()
      require("live_tests_busted")
    end,
  },
  ["snippet-converter.nvim"] = {
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
  },
  ["nvim-treesitter"] = {
    run = ":TSUpdate",
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      module = "nvim-treesitter-textobjects",
    },
    config = function()
      require("plugins.treesitter")
    end,
  },
  ["neogen"] = {
    cmd = "Neogen",
    config = function()
      require("neogen").setup {
        enabled = true,
      }
      vim.keymap.set("n", "<leader>nf", function()
        require("neogen").generate {}
      end, { silent = true })
    end,
  },
  ["lualine.nvim"] = {
    config = function()
      require("plugins.lualine")
      -- Better floating window colors
      local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
      local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
      vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=" .. normal_float_bg)
    end,
  },
  -- Color schemes
  ["github-nvim-theme"] = {
    config = function()
      require("github-theme").setup {}
    end,
  },
  -- ["shaunsingh/oxocarbon.nvim"] = {
  --   run = "./install.sh",
  -- },
  -- LSP
  ["nvim-lspconfig"] = {
    config = function()
      require("plugins.lsp.init")
    end,
  },
  ["lspsaga.nvim"] = {
    config = function()
      require("lspsaga").init_lsp_saga {
        code_action_lightbulb = {
          enable = false,
        },
      }
    end,
  },
  ["null-ls.nvim"] = {
    config = function()
      require("plugins.lsp.null_ls")
    end,
  },

  ["mason.nvim"] = {
    config = function()
      require("mason").setup()
    end,
  },
  ["fidget.nvim"] = {
    config = function()
      require("fidget").setup {
        text = {
          spinner = "dots",
        },
        timer = {
          fidget_decay = 0,
          task_decay = 0,
        },
      }
    end,
  },
  ["nvim-navic"] = {
    config = function()
      vim.g.navic_silence = true
    end,
  },
  -- Debugging
  ["nvim-dap"] = {
    config = function()
      require("plugins.dap")
    end,
  },
  -- Visual / UX enhancements
  ["windows.nvim"] = {
    config = function()
      require("windows").setup {
        animation = {
          enable = false,
        },
      }
    end,
  },
  ["inc-rename.nvim"] = {
    branch = "preview",
    -- "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup {
        async = true,
        hl_group = "IncSearch",
      }
    end,
  },
  ["noice.nvim"] = {
    event = "VimEnter",
    config = function()
      require("noice").setup {
        presets = { inc_rename = true },
      }
    end,
  },
  -- Tree viewer / file browser
  ["fern.vim"] = {
    config = function()
      require("plugins.fern")
    end,
  },
  -- Auto-completion and snippets
  ["nvim-cmp"] = {
    event = "InsertEnter",
    after = "nvim-lspconfig",
    config = function()
      require("plugins.cmp")
    end,
  },
  ["cmp-nvim-lsp"] = {
    after = "nvim-cmp",
    config = function()
      require("cmp_nvim_lsp")
    end,
  },
  ["cmp_luasnip"] = { after = "nvim-cmp" },
  ["cmp-greek"] = { after = "nvim-cmp" },
  ["cmp-buffer"] = { after = "nvim-cmp" },
  ["cmp-path"] = { after = "nvim-cmp" },
  ["LuaSnip"] = {
    -- after = "nvim-cmp",
    config = function()
      require("luasnip.loaders.from_vscode").load { paths = { "./after/my_snippets/luasnip" } }
    end,
  },
  ["telescope.nvim"] = {
    -- "~/Desktop/NeovimPlugins/telescope.nvim", requires = "nvim-lua/plenary.nvim",
    config = function()
      require("plugins.telescope")
      -- Cyan Telescope borders
      -- vim.cmd([[highlight TelescopeResultsBorder guifg=#56a5e5]])
      -- vim.cmd([[highlight TelescopePreviewBorder guifg=#56a5e5]])
      -- vim.cmd([[highlight TelescopePromptBorder guifg=#56a5e5]])
    end,
  },
  -- after = "edge",
  ["telescope-fzf-native.nvim"] = {
    run = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  -- Better :Telescope oldfiles
  ["telescope-recent-files"] = {
    config = function()
      require("telescope").load_extension("recent_files")
    end,
  },
  -- Filetype-specific plugins
  ["emmet-vim"] = {
    keys = { { "x", "<C-q>" }, { "i", "<C-q>" } },
    setup = function()
      vim.g.user_emmet_expandabbr_key = "<C-q>"
    end,
  },
  { ["vim-closetag"] = { ft = { "html", "php" } } },
  ["vimtex"] = {
    ft = "tex",
    config = function()
      vim.cmd([[autocmd User VimtexEventInitPost VimtexCompile]])
    end,
  },
  ["nvim-colorizer.lua"] = {
    config = function()
      require("colorizer").setup {
        filetypes = { "css", "html", "lua", "php" },
      }
    end,
  },
  ["vim-test"] = {
    ft = "python",
    config = function()
      -- Activate python virtual env, then run current test file in new window
      vim.g["test#python#pytest#executable"] = "source $INACON_VENV_ACTIVATE && pytest -rT -vv"
      vim.g["test#strategy"] = "neovim"
      vim.g["test#neovim#term_position"] = "vertical 80"

      -- Run tests
      map("n", "<leader>t", "<cmd>TestFile<cr>")
      -- Run nearest test
      map("n", "<leader>n", "<cmd>TestNearest<cr>")
    end,
  },
  -- New ways to manipulate text
  ["mini.nvim"] = {
    config = function()
      require("mini.ai").setup()
    end,
  },
  ["sideways.vim"] = {
    config = function()
      -- Swap function arguments using Alt + arrow keys
      map("n", "<A-left>", "<cmd>SidewaysLeft<cr>")
      map("n", "<A-right>", "<cmd>SidewaysRight<cr>")
    end,
  },
  -- "Schlepp" text around while respecting existing text
  ["vim-schlepp"] = {
    config = function()
      map("v", "<up>", "<Plug>SchleppUp", { noremap = false })
      map("v", "<down>", "<Plug>SchleppDown", { noremap = false })
      map("v", "<left>", "<Plug>SchleppLeft", { noremap = false })
      map("v", "<right>", "<Plug>SchleppRight", { noremap = false })
    end,
  },
  ["Comment.nvim"] = {
    config = function()
      require("Comment").setup()
    end,
  },
  ["nvim-autopairs"] = {
    after = "nvim-cmp",
    config = function()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("nvim-autopairs").setup {
        break_undo = false,
        disable_filetype = { "TelescopePrompt", "vim", "tex" },
        -- Insert brackets after selecting function from cmp
        require("cmp").event:on(
          "confirm_done",
          cmp_autopairs.on_confirm_done {
            map_char = { tex = "" },
          }
        ),
      }
    end,
  },
  ["auto-session"] = {
    config = function()
      require("auto-session").setup {
        auto_restore_enabled = false,
      }
    end,
  },
  -- "ggandor/lightspeed.nvim",
  ["leap.nvim"] = {
    config = function()
      require("leap").set_default_keymaps()
    end,
  },
  -- Git
  ["vim-fugitive"] = {
    config = function()
      require("plugins.fugitive")
    end,
  },
  -- Writing to-do lists, emails etc.
  ["vimwiki"] = {
    branch = "dev",
    -- keys = "<leader>x",
    config = function()
      vim.g.vimwiki_list = {
        {
          template_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/vimwiki/autoload/",
          syntax = "markdown",
          ext = ".md",
        },
      }
      vim.g["vimwiki_global_ext"] = 0
      -- doesn't seem to work, use syntax file instead
      -- vim.g["vimwiki_listsyms"] = "☒⊡⬕"
      vim.keymap.set("n", "<leader>x", "<Plug>VimwikiIndex")
    end,
  },
  ["markdown-preview.nvim"] = {
    run = "cd app && npm install",
    ft = { "markdown", "text" },
    config = function()
      vim.g["mkdp_auto_close"] = 0
      vim.g["mkdp_filetypes"] = { "markdown", "text" }
      map("n", "<leader>m", "<Plug>MarkdownPreviewToggle", { noremap = false })
    end,
  },
  -- Misc
  ["firenvim"] = {
    run = function()
      vim.fn["firenvim#install"](0)
    end,
  },
  ["stabilize.nvim"] = {
    config = function()
      -- Workaround for error that occurs when using vim-fugitive and stabililize.nvim
      -- at the same time. See https://github.com/luukvbaal/stabilize.nvim/issues/6.
      vim.cmd([[
    autocmd WinNew * lua win=vim.api.nvim_get_current_win() vim.defer_fn(
    \function() vim.api.nvim_set_current_win(win) end, 50
    \)
    ]])
      require("stabilize").setup()
    end,
  },
}
