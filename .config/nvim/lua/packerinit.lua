local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  PackerBootstrap = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
end

-- Global settings
vim.g["snippet_engine"] = "ultisnips"
vim.cmd("colorscheme github_dark")

require("packer").startup {
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float {
          border = "single",
        }
      end,
    },
  },
  function(use)
    use {
      "wbthomason/packer.nvim",
      config = function()
        local map = require("utils").map
        map("n", "<leader>c", "<cmd>PackerClean<cr>")
        map("n", "<leader>u", "<cmd>PackerSync<cr>")
        map("n", "<leader>i", "<cmd>PackerInstall<cr>")
      end,
    }

    use {
      "garbas/vim-snipmate",
      requires = { "marcweber/vim-addon-mw-utils", "tomtom/tlib_vim" },
      disable = true,
      setup = function()
        -- vim.g.snipMate.snippet_version = 1
      end,
    }

    use {
      -- "~/Desktop/NeovimPlugins/inc-rename.nvim",
      "smjonas/inc-rename.nvim",
      config = function()
        require("inc_rename").setup {}
        -- require("dressing").setup {
        --   input = {
        --     override = function(conf)
        --       conf.col = -1
        --       conf.row = 0
        --       return conf
        --     end,
        --   },
        -- }
      end,
      -- requires = "stevearc/dressing.nvim",
    }

    use {
      -- "smjonas/snippet-converter.nvim",
      "~/Desktop/NeovimPlugins/snippet-converter.nvim",
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

        -- local vscode_to_ultisnips = {
        --   name = "vscode_to_ultisnips",
        --   sources = {
        --     vscode = {
        --       "~/.config/nvim/after/my_snippets/vscode",
        --     },
        --   },
        --   output = {
        --     ultisnips = {
        --       "~/.config/nvim/after/my_snippets/ultisnips",
        --     },
        --   },
        -- }

        snippet_converter.setup {
          templates = { ultisnips_to_luasnip },
        }
      end,
      requires = "gillescastel/latex-snippets",
    }

    -- Treesitter
    use {
      -- "nvim-treesitter/nvim-treesitter",
      "~/Desktop/NeovimPlugins/nvim-treesitter",
      run = ":TSUpdate",
      requires = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/playground",
        module = "nvim-treesitter-textobjects",
      },
      config = function()
        require("plugins.treesitter")
      end,
    }

    -- Function annotation generator
    use {
      "danymat/neogen",
      cmd = "Neogen",
      config = function()
        require("neogen").setup {
          enabled = true,
        }
        vim.keymap.set("n", "<leader>nf", function()
          require("neogen").generate {}
        end, { silent = true })
      end,
    }

    -- Color schemes
    use(require("colorschemes"))

    -- Status line
    use {
      -- Change font to Powerline compatible font
      "nvim-lualine/lualine.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("plugins.lualine")
        -- Better floating window colors
        local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
        local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
        vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=" .. normal_float_bg)
      end,
    }

    -- LSP
    use {
      {
        "neovim/nvim-lspconfig",
        config = function()
          require("plugins.lsp.init")
        end,
        requires = { "folke/lua-dev.nvim" },
      },
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require("plugins.lsp.null_ls")
        end,
      },
      "williamboman/nvim-lsp-installer",
      {
        "j-hui/fidget.nvim",
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
      {
        "SmiteshP/nvim-navic",
        config = function()
          vim.g.navic_silence = true
        end,
      },
    }

    -- Debugging
    use {
      "mfussenegger/nvim-dap",
      config = function()
        require("plugins.dap")
      end,
      requires = "jbyuki/one-small-step-for-vimkind",
    }

    -- Tree viewer / file browser
    use {
      "lambdalisue/fern.vim",
      requires = "lambdalisue/fern-hijack.vim",
      config = function()
        require("plugins.fern")
      end,
    }

    -- Auto-completion and snippets
    use {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      after = "nvim-lspconfig",
      config = function()
        require("plugins.cmp")
      end,
      requires = {
        {
          "saadparwaiz1/cmp_luasnip",
          disable = vim.g["snippet_engine"] ~= "luasnip",
          after = "nvim-cmp",
        },
        { "max397574/cmp-greek", after = "nvim-cmp" },
        { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
        { "hrsh7th/cmp-path", after = "nvim-cmp" },
        -- "hrsh7th/cmp-nvim-lua",
        {
          "hrsh7th/cmp-nvim-lsp",
          after = "nvim-cmp",
          config = function()
            require("cmp_nvim_lsp")
          end,
        },
      },
    }

    use {
      "L3MON4D3/LuaSnip",
      disable = vim.g["snippet_engine"] ~= "luasnip",
      -- after = "nvim-cmp",
      config = function()
        require("luasnip.loaders.from_vscode").load { paths = { "./after/my_snippets/luasnip" } }
      end,
    }

    use {
      "SirVer/ultisnips",
      disable = vim.g["snippet_engine"] ~= "ultisnips",
      requires = "honza/vim-snippets",
      config = function()
        vim.g.UltiSnipsEnableSnipMate = 1
      end,
    }

    -- Telescope
    use {
      {
        "nvim-telescope/telescope.nvim",
        requires = "nvim-lua/plenary.nvim",
        -- "~/Desktop/NeovimPlugins/telescope.nvim", requires = "nvim-lua/plenary.nvim",
        config = function()
          require("plugins.telescope")
          -- Cyan Telescope borders
          -- vim.cmd([[highlight TelescopeResultsBorder guifg=#56a5e5]])
          -- vim.cmd([[highlight TelescopePreviewBorder guifg=#56a5e5]])
          -- vim.cmd([[highlight TelescopePromptBorder guifg=#56a5e5]])
        end,
        -- after = "edge",
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
        after = "telescope.nvim",
      },
    }

    -- Filetype specific plugins
    use {
      "mattn/emmet-vim",
      keys = { { "x", "<C-q>" }, { "i", "<C-q>" } },
      setup = function()
        vim.g.user_emmet_expandabbr_key = "<C-q>"
      end,
    }
    use { "alvan/vim-closetag", ft = { "html", "php" } }
    use {
      "lervag/vimtex",
      ft = "tex",
      config = function()
        vim.cmd([[autocmd User VimtexEventInitPost VimtexCompile]])
      end,
    }
    use {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup {
          "css",
          "html",
          "lua",
          "php",
          -- { default_options = { names = false } }
        }
      end,
    }

    use {
      "vim-test/vim-test",
      ft = "python",
      config = function()
        -- Activate python virtual env, then run current test file in new window
        vim.g["test#python#pytest#executable"] = "source $INACON_VENV_ACTIVATE && pytest -rT -vv"
        vim.g["test#strategy"] = "neovim"
        vim.g["test#neovim#term_position"] = "vertical 80"

        local map = require("utils").map
        -- Run tests
        map("n", "<leader>t", "<cmd>TestFile<cr>")
        -- Run nearest test
        map("n", "<leader>n", "<cmd>TestNearest<cr>")
      end,
    }

    -- New ways to manipulate text
    use {
      "wellle/targets.vim",
      -- E.g. dav to delete b from a_b_c => a_c
      { "Julian/vim-textobj-variable-segment", requires = "kana/vim-textobj-user" },
      -- gr textobject
      { "inkarkat/vim-ReplaceWithRegister" },
      {
        "AndrewRadev/sideways.vim",
        config = function()
          local map = require("utils").map
          -- Swap function arguments using Alt + arrow keys
          map("n", "<A-left>", "<cmd>SidewaysLeft<cr>")
          map("n", "<A-right>", "<cmd>SidewaysRight<cr>")
        end,
      },
      {
        "machakann/vim-sandwich",
        config = function()
          require("plugins.vim_sandwich")
        end,
      },
      {
        -- "Schlepp" text around while respecting existing text
        "zirrostig/vim-schlepp",
        config = function()
          local map = require("utils").map
          map("v", "<up>", "<Plug>SchleppUp", { noremap = false })
          map("v", "<down>", "<Plug>SchleppDown", { noremap = false })
          map("v", "<left>", "<Plug>SchleppLeft", { noremap = false })
          map("v", "<right>", "<Plug>SchleppRight", { noremap = false })
        end,
      },
    }

    use {
      "terrortylor/nvim-comment",
      config = function()
        require("nvim_comment").setup {
          comment_empty = false,
          hook = function()
            require("ts_context_commentstring.internal").update_commentstring {}
          end,
        }
      end,
      requires = "JoosepAlviste/nvim-ts-context-commentstring",
    }

    use {
      "windwp/nvim-autopairs",
      after = "nvim-cmp",
      config = function()
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        require("nvim-autopairs").setup {
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
    }

    use {
      "rmagatti/auto-session",
      config = function()
        require("auto-session").setup {
          auto_restore_enabled = false,
        }
      end,
    }

    use {
      -- "ggandor/lightspeed.nvim",
      "ggandor/leap.nvim",
      config = function()
        require("leap").set_default_keymaps()
      end,
    }

    -- Git
    use {
      "tpope/vim-fugitive",
      config = function()
        require("plugins.fugitive")
      end,
    }

    -- Writing to-do lists, emails etc.
    use {
      "vimwiki/vimwiki",
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
    }

    use {
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      ft = { "markdown", "text" },
      config = function()
        vim.g["mkdp_auto_close"] = 0
        vim.g["mkdp_filetypes"] = { "markdown", "text" }
        local map = require("utils").map
        map("n", "<leader>m", "<Plug>MarkdownPreviewToggle", { noremap = false })
      end,
    }

    use {
      "nvim-neorg/neorg",
      disable = true,
      branch = "unstable",
      requires = "nvim-lua/plenary.nvim",
      -- after = "nvim-treesitter",
      config = function()
        require("plugins.neorg")
      end,
    }

    use {
      -- rtp in packer has some issues, that's why I have to use the local path
      vim.fn.stdpath("data") .. "/himalaya/vim",
      disable = true,
      -- rtp = "vim",
      -- config = function()
      --   vim.g["himalaya_mailbox_picker"] = "telescope"
      -- end
    }

    -- Misc

    use {
      "glacambre/firenvim",
      run = function()
        vim.fn["firenvim#install"](0)
      end,
    }

    use {
      "luukvbaal/stabilize.nvim",
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
    }

    use("dstein64/vim-startuptime")

    use("arp242/undofile_warn.vim")

    use("tpope/vim-repeat")

    use("lewis6991/impatient.nvim")

    use {
      "github/copilot.vim",
      -- disable = true,
      config = function()
        require("plugins.copilot")
      end,
    }

    if PackerBootstrap then
      require("packer").sync()
    end
  end,
}
