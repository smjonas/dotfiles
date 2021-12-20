---@diagnostic disable: different-requires

local fn = vim.fn
local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PackerBootstrap = fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
end

-- global settings
vim.g["snippet_engine"] = "ultisnips"
vim.g["completion_plugin"] = "cmp"

require("packer").startup(function(use)
  -- Workaround for plugins with the rtp option (https://github.com/soywod/himalaya/issues/188)
  -- local packer_compiled = vim.fn.stdpath("config") .. "/plugin/packer_compiled.lua"
  -- vim.cmd("luafile"  .. packer_compiled)

  use {
    "wbthomason/packer.nvim",
    config = function()
      local map = require("utils").map
      map("n", "<leader>c", "<cmd>PackerClean<cr>")
      map("n", "<leader>u", "<cmd>PackerUpdate<cr>")
      map("n", "<leader>i", "<cmd>PackerInstall<cr>")
    end
  }

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter", run = ":TSUpdate",
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      module = "nvim-treesitter-textobjects"
    },
    config = function()
      require("plugins.treesitter")
    end
  }

  -- Color schemes
  use {
    {
      "joshdick/onedark.vim"
    },
    {
      "sainnhe/edge",
      config = function()
        vim.g["edge_enable_italic"] = 1
        vim.g["edge_disable_italic_comment"] = 1
        vim.cmd[[colorscheme edge]]
      end
    },
    {
      "sainnhe/gruvbox-material",
      setup = function()
        vim.g.gruvbox_material_palette = "mix"
        vim.g.gruvbox_material_background = "medium"
        vim.g.gruvbox_material_transparent_background = 0
      end
    },
    { "ghifarit53/tokyonight-vim" },
    {
      "navarasu/onedark.nvim",
      setup = function() vim.g.onedark_style = "warmer" end
    }
  }

  -- Status bar
  use {
    -- Change font to Powerline compatible font in Edit > Preferences (bash)
    -- or set the font in ~/.config/alacritty/alacritty.yml
    -- after installing by cloning git@github.com:powerline/fonts.git
    -- and running ./install.sh
    "nvim-lualine/lualine.nvim", requires = "kyazdani42/nvim-web-devicons",
    config = function() require("plugins.lualine") end,
    after = "edge"
  }

  -- LSP
  use {
    {
      "neovim/nvim-lspconfig",
      config = function() require("plugins.lsp.init") end,
      after = "nvim-cmp"
    },
    "williamboman/nvim-lsp-installer",
    {
      "tami5/lspsaga.nvim",
      config = function()
        require("lspsaga").init_lsp_saga {
          error_sign = ">>",
          warn_sign = ">>"
        }
        local map = require("utils").map
        map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
        map("n", "<F2>", "<cmd>lua require('lspsaga.rename').rename()<cr>")
      end
    },
    {
      "ray-x/lsp_signature.nvim", disable = true,
      config = function()
        require("lsp_signature").setup {
          floating_window = true,
        }
      end
    },
    {
      "weilbith/nvim-code-action-menu", disable = true,
      config = function()
        vim.g["code_action_menu_show_details"] = false
        local map = require("utils").map
        map("n", "ga", "<cmd>CodeActionMenu<cr>")
      end
    },
    {
      -- Modified version of mfussenegger/nvim-lint,
      "jonasstr/nvim-lint",
      config = function()
        require("lint").linters_by_ft = { python = { "flake8" } }
        vim.cmd[[autocmd BufEnter,BufWritePost * lua require("lint").try_lint()]]
      end
    }
  }

  -- Tree viewer / file browser
  use {
    "lambdalisue/fern.vim", disable = false,
    config = function() require("plugins.fern") end
  }

  use {
    "kyazdani42/nvim-tree.lua", requires = "kyazdani42/nvim-web-devicons", disable = true,
    config = function()
      vim.g["nvim_tree_group_empty"] = 1
      vim.g["nvim_tree_respect_buf_cwd"] = 1
      vim.g["nvim_tree_root_folder_modifier"] = ":t:r"

      local tree_cb = require("nvim-tree.config").nvim_tree_callback
      local mappings = {
        { key = { "h" }, cb = tree_cb("close_node") },
        { key = { "l" }, cb = tree_cb("edit") },
      }
      require("nvim-tree").setup {
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          mappings = {
            list = mappings
          }
        },
      }

      local map = require("utils").map
      map("n", "<C-n>", "<cmd>NvimTreeToggle<cr>")
    end
  }

  -- Auto-completion and snippets
  use {
    {
      "ms-jpq/coq_nvim", disable = vim.g["completion_plugin"] ~= "coq", branch = "coq",
      setup = function() require("plugins.coq") end
    },
    {
      "ms-jpq/coq.artifacts", disable = vim.g["completion_plugin"] ~= "coq",
      branch = "artifacts", after = "coq_nvim"
    }
  }

  use {
    "hrsh7th/nvim-cmp", config = function() require("plugins.cmp") end,
    requires = {
      {
        "~/Desktop/cmp-nvim-ultisnips", branch = "regex_snippets",
        -- "smjonas/cmp-nvim-ultisnips", branch = "refactor",
        -- "quangnguyen30192/cmp-nvim-ultisnips",
        disable = vim.g["snippet_engine"] ~= "ultisnips",
        config = function()
          require("cmp_nvim_ultisnips").setup {
            filetype_source = "treesitter"
          }
        end
      },
      {
        "saadparwaiz1/cmp_luasnip",
        disable = vim.g["snippet_engine"] ~= "luasnip",
        after = "LuaSnip"
      },
      "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-nvim-lua",
      { "hrsh7th/cmp-nvim-lsp", config = function() require("cmp_nvim_lsp") end },
      "lukas-reineke/cmp-under-comparator",
    },
  }

  use {
    "L3MON4D3/LuaSnip",
    config = function() require("plugins.luasnip") end,
  }

  use {
    "~/Desktop/NeovimPlugins/UltiSnips",
    -- "SirVer/ultisnips",
    requires = "honza/vim-snippets",
    config = function()
      vim.g.UltiSnipsEnableSnipMate = 1
    end
  }

  -- Telescope
  use {
    {
      "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim",
      -- "~/Desktop/NeovimPlugins/telescope.nvim", requires = "nvim-lua/plenary.nvim",
      config = function()
        require("plugins.telescope")
        -- Cyan Telescope borders
        vim.cmd[[highlight TelescopeResultsBorder guifg=#56a5e5]]
        vim.cmd[[highlight TelescopePreviewBorder guifg=#56a5e5]]
        vim.cmd[[highlight TelescopePromptBorder guifg=#56a5e5]]
      end,
      after = "edge"
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim", run = "make",
      config = function() require("telescope").load_extension("fzf") end,
      after = "telescope.nvim"
    },
    {
      "nvim-telescope/telescope-frecency.nvim", disable = true,
      requires = "tami5/sqlite.lua",
      config = function() require("telescope").load_extension("frecency") end,
      after = "telescope.nvim"
    },
    {
      "ahmedkhalf/project.nvim", disable = true,
      config = function()
        require("project_nvim").setup { silent_chdir = false }
        require("telescope").load_extension("projects")
      end,
      after = "telescope.nvim"
    }
  }

  -- Filetype specific plugins
  use {
    "mattn/emmet-vim",
    keys = { {"x", "<C-q>" }, {"i", "<C-q>" } },
    setup = function() vim.g.user_emmet_expandabbr_key = "<C-q>" end
  }
  use { "alvan/vim-closetag", ft = { "html", "php" } }
  use { "lervag/vimtex", ft = "tex",
    config = function()
      vim.cmd[[autocmd User VimtexEventInitPost VimtexCompile]]
    end
  }
  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup {
        "css"; "html"; "lua"; "php";
        -- { default_options = { names = false } }
      }
    end
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
    end
  }

-- New ways to manipulate text
  use {
    "wellle/targets.vim",
    -- E.g. dav to delete b from a_b_c => a_c
    { "Julian/vim-textobj-variable-segment", requires = "kana/vim-textobj-user" },
    { "AndrewRadev/sideways.vim",
      config = function()
        local map = require("utils").map
        -- Swap function arguments using Alt + arrow keys
        map("n", "<A-left>", "<cmd>SidewaysLeft<cr>")
        map("n", "<A-right>", "<cmd>SidewaysRight<cr>")
      end
    },
    { "machakann/vim-sandwich", config = function() require("plugins.vim-sandwich") end },
    {
      -- "Schlepp" text around while respecting existing text
      "zirrostig/vim-schlepp",
      config = function()
        local map = require("utils").map
        map("v", "<up>", "<Plug>SchleppUp", { noremap = false })
        map("v", "<down>", "<Plug>SchleppDown", { noremap = false })
        map("v", "<left>", "<Plug>SchleppLeft", { noremap = false })
        map("v", "<right>", "<Plug>SchleppRight", { noremap = false })
      end
    }
  }

  use {
    "terrortylor/nvim-comment",
    config = function()
      require("nvim_comment").setup {
        comment_empty = false,
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end
      }
    end,
    requires = "JoosepAlviste/nvim-ts-context-commentstring"
  }

  use {
    "windwp/nvim-autopairs",
    config = function()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("nvim-autopairs").setup {
        disable_filetype = { "TelescopePrompt", "vim", "tex" };
        -- Insert brackets after selecting function from cmp
        require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done {
           map_char = { tex = "" }
        });
      }
    end,
    after = "nvim-cmp"
  }

  use {
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup {
        -- Need to type RestoreSession manually
        auto_restore_enabled = false
      }
    end
  }

  use {
    "beauwilliams/focus.nvim", disable = true,
    config = function()
      require("focus").setup { hybridnumber = true }
      require("utils").map("n", "<C-a>", "<cmd>FocusSplitNicely<cr>")
    end
  }

  use {
    "ggandor/lightspeed.nvim",
    config = function()
      -- Remap to Alt + s to preserve default behaviour of S
      require("utils").map("n", "<M-s>", "<Plug>Lightspeed_S", { noremap = false })
    end
  }

  use {
    "tpope/vim-fugitive",
    config = function() require("plugins.fugitive") end
  }

  use {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup {
        mapping = { "ii" },
      }
    end
  }

  -- Writing to-do lists, emails etc.

  use {
    "vimwiki/vimwiki", branch = "dev",
    -- keys = { "<leader>x" },
    config = function()
      vim.g["vimwiki_list"] = {
        {
          template_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/vimwiki/autoload/",
          syntax = "markdown", ext = ".md"
        }
      }
      vim.g["vimwiki_global_ext"] = 0
      local map = require("utils").map
      map("n", "<leader>x", "<Plug>VimwikiIndex", { noremap = false, unique = false })
      -- doesn't seem to work, use syntax file instead
      -- vim.g["vimwiki_listsyms"] = "☒⊡⬕"
    end
  }

  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = { "markdown", "text" },
    config = function ()
      vim.g["mkdp_auto_close"] = 0
      vim.g["mkdp_filetypes"] = { "markdown", "text" }

      local map = require("utils").map
      map("n", "<leader>m", "<Plug>MarkdownPreviewToggle", { noremap = false })
    end
  }

  use {
    "nvim-neorg/neorg", disable = true, branch = "unstable",
    requires = "nvim-lua/plenary.nvim",
    -- after = "nvim-treesitter",
    config = function()
      require("plugins.neorg")
    end
  }

  use {
    -- rtp in packer has some issues, that's why I have to use the local path
    vim.fn.stdpath("data") .. "/himalaya/vim",
    -- rtp = "vim",
    -- config = function()
      --   vim.g["himalaya_mailbox_picker"] = "telescope"
      -- end
  }

  -- use { "michaelb/sniprun", run = "bash ./install.sh" }

  -- Misc

  use {
    "glacambre/firenvim",
    run = function() vim.fn["firenvim#install"](0) end
  }

  use {
    "luukvbaal/stabilize.nvim",
    disable = vim.bo.ft ~= "vimwiki",
    config = function()
      -- Workaround for error that occurs when using vim-fugitive and stabililize.nvim
      -- at the same time. See https://github.com/luukvbaal/stabilize.nvim/issues/6.
      vim.cmd[[
        autocmd WinNew * lua win=vim.api.nvim_get_current_win() vim.defer_fn(
          \function() vim.api.nvim_set_current_win(win) end, 50
        \)
      ]]
      require("stabilize").setup()
    end
  }

  use "arp242/undofile_warn.vim"

  use "tpope/vim-repeat"

  use {
    "github/copilot.vim", disable = true,
    config = function() require("plugins.copilot") end
  }

  if PackerBootstrap then
    require("packer").sync()
  end
end)
