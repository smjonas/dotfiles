let $INACON_DIR = $HOME . "/Desktop/Inacon/"
let $INACON_VENV_ACTIVATE = $INACON_DIR . "inacon_env/bin/activate"
let $INACON_VENV_PYTHON = $INACON_DIR . "inacon_env/bin"

" Directory for plugins
call plug#begin(stdpath('data') . '/plugged')

Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" Color schemes
Plug 'sainnhe/gruvbox-material'
  let g:gruvbox_material_palette = "mix"
  let g:gruvbox_material_background = "medium"
  let g:gruvbox_material_transparent_background = 1
Plug 'ghifarit53/tokyonight-vim'
  let g:tokyonight_transparent_background = 1
Plug 'navarasu/onedark.nvim'
  let g:onedark_style = "warmer"

Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'tami5/lspsaga.nvim'
Plug 'ray-x/lsp_signature.nvim'
" Modified version of mfussenegger/nvim-lint
Plug 'jonasstr/nvim-lint'

Plug 'ms-jpq/coq_nvim', { 'branch': 'coq' }
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', {'branch': 'master'}
" Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

Plug 'tami5/sqlite.lua'
  Plug 'nvim-telescope/telescope-frecency.nvim'
  " Plug 'nvim-telescope/telescope-cheat.nvim', { 'commit': '7322a73' }

Plug 'ahmedkhalf/project.nvim'

" File browser:
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/fern.vim'
  let g:fern#drawer_width = 50

Plug 'shadmansaleh/lualine.nvim' ", {'commit': 'dc2c711'}
" Change font to Powerline compatible font in Edit > Preferences (bash)
" or set the font in ~/.config/alacritty/alacritty.yml
" after installing by cloning git@github.com:powerline/fonts.git
" and running ./install.sh
Plug 'kyazdani42/nvim-web-devicons'

" Activate python virtual env, then run current test file in new window
Plug 'vim-test/vim-test'
  let g:test#python#pytest#executable = 'source $INACON_VENV_ACTIVATE && pytest -rT -vv'
  let g:test#strategy = 'neovim'
  let test#neovim#term_position = 'vertical 80'
" Make LSP client recognize python virtual env
" Plug 'HallerPatrick/py_lsp.nvim'
  " Plug 'nvim-lua/completion-nvim'
Plug 'lervag/vimtex'

" New text objects
Plug 'wellle/targets.vim'

" E.g. dav to delete b from a_b_c => a_c
Plug 'Julian/vim-textobj-variable-segment'
  Plug 'kana/vim-textobj-user'

" Auto-close / html plugins
Plug 'windwp/nvim-autopairs'
Plug 'mattn/emmet-vim'
Plug 'alvan/vim-closetag'

Plug 'b3nj5m1n/kommentary'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
" Allows to repeat vim surround commands, e.g. cs'"
Plug 'tpope/vim-repeat'
Plug 'rmagatti/auto-session'

" Swap function arguments using Alt + arrow keys
Plug 'AndrewRadev/sideways.vim'

" Remap to Alt + s to preserve default behaviour of S
nmap <M-s> <Plug>Lightspeed_S
Plug 'ggandor/lightspeed.nvim'
Plug 'beauwilliams/focus.nvim'

" Misc
Plug 'arp242/undofile_warn.vim'
" Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'chrisbra/Colorizer'
  let g:colorizer_auto_filetype='css,html,php,lua'
call plug#end()

" Fixes wrong colors in Vim when using tmux
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

colorscheme onedark

lua << EOF
-- Load config files from ~/.config/nvim/lua/
require("options")
require("plugins")
EOF
runtime mappings.vim

augroup MY_AUTO_GROUP
    au!
    " Run on startup for faster keyboard movement
    au VimEnter * silent !xset r rate 250 33

    " Remove trailing whitespace on save (/e to hide errors)
    au BufWritePre * %s/\s\+$//e

    " Equalize splits after resizing
    au VimResized * wincmd =

    " Do not auto-wrap text, only comments. This does not work when set
    " as a global option (see https://vi.stackexchange.com/a/9367/37072)
    au FileType * set formatoptions-=t

    au BufRead python setlocal foldmethod=indent foldnestmax=1
    au BufEnter python PyLspReloadVenv
    " nvim-lint
    au BufEnter,BufWritePost * lua require("lint").try_lint()
    " vimtex
    au User VimtexEventInitPost VimtexCompile

    " Automatically enter insert mode when in terminal mode
    " and change to current directory
    au TermOpen * silent !lcd %:p:h
    au TermOpen * startinsert

    " 2 spaces per tab for php files
    au FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
    au FileType html,vim setlocal shiftwidth=2 tabstop=2 expandtab
augroup end

