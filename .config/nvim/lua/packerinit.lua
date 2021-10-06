
function P(table)
  print(vim.inspect(table))
  return table
end

require('packer').startup(function()

  use {
    'wbthomason/packer.nvim',
    config = function()
      local map = require('utils').map
      map('n', '<leader>c', '<cmd>PackerClean<cr>')
      map('n', '<leader>u', '<cmd>PackerUpdate<cr>')
      map('n', '<leader>i', '<cmd>PackerInstall<cr>')
    end
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter', run = ':TSUpdate',
    requires = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      module = 'nvim-treesitter-textobjects'
    },
    config = function()
      require('plugins.treesitter')
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
        vim.g.gruvbox_material_transparent_background = 0
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
      config = function() require('plugins.lsp') end,
    },
    'kabouzeid/nvim-lspinstall',
    {
      'tami5/lspsaga.nvim',
      config = function()
        require('lspsaga').init_lsp_saga {
          error_sign = '>>',
          warn_sign = '>>'
        }
        local map = require('utils').map
        map('n', '<F1>', '<cmd>lua require("lspsaga.hover").render_hover_doc()<cr>')
        map('n', '<F2>', '<cmd>lua require("lspsaga.rename").rename()<cr>')
        map('n', '<leader>ga', '<cmd>lua require("lspsaga.codeaction").code_action()<cr>')
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
    config = function()
      vim.g['fern#drawer_width'] = 50
      local map = require('utils').map
      map('n', '<C-n>', '<cmd>Fern %:h -drawer -toggle<cr>')
      map('n', '<M-n>', '<cmd>Fern %:h<cr>')
    end
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
    ft = { 'html', 'php' },
    setup = function() vim.g.user_emmet_expandabbr_key = '<C-q>' end
  }

  use { 'alvan/vim-closetag', ft = { 'html', 'php' } }

  use { 'lervag/vimtex', ft = 'tex' }

  use {
    'chrisbra/Colorizer',
    setup = function()
      vim.g.colorizer_auto_filetype = 'css,html,php,lua'
      vim.g.colorizer_colornames = 0
    end
  }

  use {
    'vim-test/vim-test',
    ft = 'python',
    config = function()
      -- Activate python virtual env, then run current test file in new window
      vim.g['test#python#pytest#executable'] = 'source $INACON_VENV_ACTIVATE && pytest -rT -vv'
      vim.g['test#strategy'] = 'neovim'
      vim.g['test#neovim#term_position'] = 'vertical 80'

      local map = require('utils').map
      -- Run tests
      map('n', '<leader>t', '<cmd>TestFile<cr>')
      -- Run nearest test
      map('n', '<leader>n', '<cmd>TestNearest<cr>')
    end
  }

  -- Misc

  -- New ways to manipulate text
  use {
    'wellle/targets.vim',
    -- E.g. dav to delete b from a_b_c => a_c
    { 'Julian/vim-textobj-variable-segment', requires = 'kana/vim-textobj-user' },
    { 'AndrewRadev/sideways.vim',
    config = function()
      local map = require('utils').map
      -- Sideways text objects to select arguments
      map('o', 'aa', '<Plug>SidewaysArgumentTextobjA')
      map('x', 'aa', '<Plug>SidewaysArgumentTextobjA')
      map('o', 'ia', '<Plug>SidewaysArgumentTextobjI')
      map('x', 'ia', '<Plug>SidewaysArgumentTextobjI')

      -- Swap function arguments using Alt + arrow keys
      map('n', '<M-h>', '<cmd>SidewaysLeft<cr>')
      map('n', '<M-l>', '<cmd>SidewaysRight<cr>')
    end
  },
  { 'machakann/vim-sandwich' },
  {
    -- 'Schlepp' text around while respecting existing text
    'zirrostig/vim-schlepp',
    config = function()
      local map = require('utils').map
      map('v', '<up>', '<Plug>SchleppUp', { noremap = false })
      map('v', '<down>', '<Plug>SchleppDown', { noremap = false })
      map('v', '<left>', '<Plug>SchleppLeft', { noremap = false })
      map('v', '<right>', '<Plug>SchleppRight', { noremap = false })
    end
  }
}

use {
  'b3nj5m1n/kommentary',
  config = function()
    local kommentary = require('kommentary.config')
    kommentary.configure_language('default', { prefer_single_line_comments = true })
    kommentary.configure_language('java', { prefer_single_line_comments = false })
  end
}

use {
  'windwp/nvim-autopairs',
  config = function()
    require('nvim-autopairs').setup {
      disable_filetype = { 'TelescopePrompt' , 'vim', 'tex' }
    }
  end
}

use {
  'rmagatti/auto-session',
  config = function()
    require('auto-session').setup {
      -- Need to type RestoreSession manually
      auto_restore_enabled = false
    }
  end
}

use {
  'beauwilliams/focus.nvim',
  config = function()
    require('focus').setup { hybridnumber = true }
    require('utils').map('n', '<C-a>', '<cmd>FocusSplitNicely<cr>')
  end
}

use {
  'ggandor/lightspeed.nvim',
  config = function()
    -- Remap to Alt + s to preserve default behaviour of S
    require('utils').map('n', '<M-s>', '<Plug>Lightspeed_S', { noremap = false })
  end
}

use {
  'tpope/vim-fugitive',
  config = function()
    local map = require('utils').map
    map('n', '<leader>gs', '<cmd>Git<cr>')
    -- Simpler git commit than vim-fugitive
    map('n', '<leader>gc', ':Git commit -m')
    map('n', '<leader>gp', '<cmd>Git push<cr>')
  end
}

use 'arp242/undofile_warn.vim'

use 'tpope/vim-repeat'

    end)

