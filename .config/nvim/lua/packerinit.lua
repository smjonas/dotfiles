
function P(table)
  print(vim.inspect(table))
  return table
end

require('packer').startup(function()

  local map = require('utils').map

  use 'wbthomason/packer.nvim'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
    config = function()
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = false
        },
        textobjects = {
          select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner'
            }
          }
        }
      }
    end
  }

  -- Color schemes
  use {
    { 'sainnhe/edge' },
    {
      'sainnhe/gruvbox-material',
      setup = function()
        vim.g.gruvbox_material_palette = 'mix'
        vim.g.gruvbox_material_background = 'medium'
        vim.g.gruvbox_material_transparent_background = 1
      end
    },
    { 'ghifarit53/tokyonight-vim' },
    {
      'navarasu/onedark.nvim',
      setup = function() vim.g.onedark_style = 'warmer' end
    }
  }

  -- Status bar
  use {
    -- Change font to Powerline compatible font in Edit > Preferences (bash)
    -- or set the font in ~/.config/alacritty/alacritty.yml
    -- after installing by cloning git@github.com:powerline/fonts.git
    -- and running ./install.sh
    'shadmansaleh/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons',
    config = function() require('plugins.lualine') end
  }

  -- LSP
  use {
    {
      'neovim/nvim-lspconfig',
      config = function() require('plugins.lsp') end
    },
    'kabouzeid/nvim-lspinstall',
    {
      'tami5/lspsaga.nvim',
      config = function()
        require("lspsaga").init_lsp_saga {
          error_sign = '>>',
          warn_sign = '>>'
        }
      end
    },
    'ray-x/lsp_signature.nvim',
    {
      -- Modified version of mfussenegger/nvim-lint,
      'jonasstr/nvim-lint',
      config = function()
        require('lint').linters_by_ft = { python = {'flake8'} }
      end
    }
  }

  -- Tree viewer / file browser
  use {
    'lambdalisue/fern.vim', requires = 'antoinemadec/FixCursorHold.nvim',
    setup = function() vim.g['fern#drawer_width'] = 50 end
  }

  -- Auto-completion
  use {
    {
      'ms-jpq/coq_nvim', branch = 'coq',
      setup = function() require('plugins.coq') end
    },
    { 'ms-jpq/coq.artifacts', branch = 'artifacts', after = 'coq_nvim' }
  }

  -- Telescope
  use {
    {
      'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim',
      config = function() require('plugins.telescope') end
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim', run = 'make',
      config = function() require('telescope').load_extension('fzf') end,
      after = 'telescope.nvim'
    },
    {
      'nvim-telescope/telescope-frecency.nvim', requires = 'tami5/sqlite.lua',
      config = function() require('telescope').load_extension('frecency') end,
      after = 'telescope.nvim'
    },
    {
      'ahmedkhalf/project.nvim',
      config = function()
        require('project_nvim').setup { silent_chdir = false }
        require('telescope').load_extension('projects')
      end,
      after = 'telescope.nvim'
    }
  }

  -- Filetype specific plugins
  use {
    'mattn/emmet-vim',
    ft = {'html', 'php'},
    setup = function() vim.g.user_emmet_expandabbr_key = "<C-q>" end
  }

  use { 'alvan/vim-closetag', ft = { 'html', 'php' } }

  use { 'chrisbra/Colorizer', ft = { 'css', 'html', 'php', 'lua' } }

  use { 'lervag/vimtex', ft = { 'tex' } }

  use {
    'vim-test/vim-test',
    ft = { 'python' },
    setup = function()
      -- Activate python virtual env, then run current test file in new window
      vim.g['test#python#pytest#executable'] = 'source $INACON_VENV_ACTIVATE && pytest -rT -vv'
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'vertical 80'
    end
  }

  -- Misc

  -- New ways to manipulate text
  use {
    { 'wellle/targets.vim' },
    -- E.g. dav to delete b from a_b_c => a_c
    { 'Julian/vim-textobj-variable-segment', requires = 'kana/vim-textobj-user' },
    -- Swap function arguments using Alt + arrow keys
    { 'AndrewRadev/sideways.vim' },
    { 'tpope/vim-surround', requires = 'tpope/vim-repeat' },
    { 'zirrostig/vim-schlepp' }
  }

  use {
    'b3nj5m1n/kommentary',
    config = function()
      local kommentary = require('kommentary.config')
      kommentary.configure_language("default", { prefer_single_line_comments = true })
      kommentary.configure_language("java", { prefer_single_line_comments = false })
    end
  }

  use {
    {
      'windwp/nvim-autopairs',
      config = function()
        require("nvim-autopairs").setup {
          disable_filetype = { "TelescopePrompt" , "vim", "tex" }
        }
      end
    },
  }

  use {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        -- Need to type RestoreSession manually
        auto_restore_enabled = false
      }
    end
  }

  use {
    'beauwilliams/focus.nvim',
    config = function() require('focus').setup { hybridnumber = true } end
  }

  use {
    'ggandor/lightspeed.nvim',
    config = function()
      -- Remap to Alt + s to preserve default behaviour of S
      map('n', '<M-s>', '<Plug>Lightspeed_S')
    end
  }

  use {
    'tpope/vim-fugitive',
    'arp242/undofile_warn.vim'
  }

end)

