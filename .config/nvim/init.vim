let $INACON_DIR = "/home/jonas/Desktop/Inacon/"
let $INACON_VENV_ACTIVATE = $INACON_DIR . "inacon_env/bin/activate"
let $INACON_VENV_PYTHON = $INACON_DIR . "inacon_env/bin"
" Somehow, $XDG_CONFIG_HOME is not available
let $CONFIG_DIR = "$HOME/config/nvim"

set background=dark
" Use system clipboard
set clipboard^=unnamed,unnamedplus
" Autocomplete settings
set completeopt=menuone,noselect,preview
set cursorline
set expandtab
" Do not open folds when moving with { or }
set foldopen-=block
" Auto-save when switching to different buffer using ctrl-6
set autowriteall
set ignorecase
" Show replacement results while typing command
set inccommand=nosplit
set incsearch
" Drag window with mouse
set mouse=a
set nohlsearch
set nojoinspaces
" Current mode in insert mode is not necessary when using status line plugin
set noshowmode
set noswapfile
set nowrap
set number
set relativenumber
set scrolloff=9
set shiftround
set shiftwidth=4
" Do not display ins-completion-menu messages
set shortmess+=c
set smartcase
set splitbelow splitright
set synmaxcol=250
set tabstop=4
set t_Co=256
set termguicolors
set textwidth=90
set timeoutlen=300
set undodir=~/.vim/nvim-undo-dir
set undofile
set wildignorecase

" Directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': '0.5-compat', 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', {'branch' : '0.5-compat'}

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
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}

Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
" Plug 'hrsh7th/nvim-compe'
" Plug 'hrsh7th/vim-vsnip'
" Plug 'rafamadriz/friendly-snippets'

Plug 'glepnir/lspsaga.nvim'

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

Plug 'ahmedkhalf/project.nvim'

" File browser
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/fern.vim'
  let g:fern#drawer_width = 50

Plug 'hoob3rt/lualine.nvim', {'commit': 'dc2c711'}
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
Plug 'HallerPatrick/py_lsp.nvim'
  Plug 'nvim-lua/completion-nvim'

" New text objects
Plug 'wellle/targets.vim'

" E.g. dav to delete b from a_b_c => a_c
Plug 'Julian/vim-textobj-variable-segment'
  Plug 'kana/vim-textobj-user'

Plug 'windwp/nvim-autopairs'
Plug 'alvan/vim-closetag'

Plug 'b3nj5m1n/kommentary'

" Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
" Allows to repeat vim surround commands, e.g. cs'"
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-obsession'

" Swap function arguments using Alt + arrow keys
Plug 'AndrewRadev/sideways.vim'
Plug 'ggandor/lightspeed.nvim'
" Plug 'unblevable/quick-scope'
"   let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" Misc
Plug 'arp242/undofile_warn.vim'
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
-- Plugin settings are in ~/.config/nvim/lua/plugins.lua
require("plugins")
EOF

let mapleader = " "

nno ii <Esc>
vno ii <Esc>gV
ono ii <Esc>
ino ii <Esc>`^
cno ii <C-C><Esc>
" Remap exiting terminal mode
tno ii <C-\><C-n>

" Basic movement in insert mode
ino <C-h> <left>
ino <C-l> <right>
ino <C-j> <down>
ino <C-k> <up>

" Movement when wrap option is enabled
nno j gj
nno k gk

" Faster moving to start / end of line
nno H ^
nno L $

" Moving lines (==) for correct indentation
nno <silent> <C-k> :move-2<cr>==
nno <silent> <C-j> :move+<cr>==
nno <silent> <C-l> >>
nno <silent> <C-h> <<
xno <silent> <C-k> :move-2<cr>gv
xno <silent> <C-j> :move'>+<cr>gv
xno <silent> <C-h> <gv
xno <silent> <C-l> >gv

" Sideways text objects to select arguments
omap <silent> aa <Plug>SidewaysArgumentTextobjA
xmap <silent> aa <Plug>SidewaysArgumentTextobjA
omap <silent> ia <Plug>SidewaysArgumentTextobjI
xmap <silent> ia <Plug>SidewaysArgumentTextobjI

" Swap function arguments
nno <M-h> <cmd>SidewaysLeft<cr>
nno <M-l> <cmd>SidewaysRight<cr>

" Insert new line below and above without entering insert mode
nno <leader>o o<Esc>0"_D
nno <leader>O O<Esc>0"_D

" Use black hole register for deleting
nno <leader>d "_d
nno <leader>D "_D

" Line break from normal mode
nno <cr> myi<cr><Esc>g`y

" Yank to end of line
nno Y y$

" Avoid accidentally recording a macro
nno q <nop>
nno <leader>q q

" Do not move by accident
nno <space> <nop>

" Keep it centered (zv to open folds if necessary)
nno n nzzzv
nno N Nzzzv
" Center on buffer change
nno <C-6> <C-6>zz
nno g; g;zz
nno g, g,zz

nno J J$

" Undo break points
ino , ,<C-g>u
ino . .<C-g>u
ino _ _<C-g>u

" Jumplist mutations (O works as expected)
nno <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nno <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Search and replace
nno <leader><F2> :%s///gc<left><left><left><left>

" Circular window movements
nno <tab> <C-w>w
nno <S-tab> <C-w>W

nno <C-n> <cmd>:Fern %:h -drawer -toggle<cr>
" Use . to go up a directory
" nmap <buffer><expr> . <Plug>(fern-action-leave)

" Faster file saving and exiting
nno <leader>w <cmd>w<cr>
nno <leader>q <cmd>q<cr>
nno <leader>! <cmd>q!<cr>

" Coq remaps
ino <c-m> <cmd>lua COQnav_mark()<cr>

" -- Telescope remaps --
" Find files
nno <leader>ff <cmd>Telescope find_files hidden=true<cr>
" Find buffers
nno <leader>fb <cmd>Telescope buffers sort_mru=true<cr>
" Find Inacon
nno <leader>fi <cmd>lua require("telescope.builtin").find_files (
    \{search_dirs = { vim.env.INACON_DIR .. "/Kurse", vim.env.INACON_DIR .. "/Automation" } }
\)<cr>
" Find old in Inacon
nno <leader>fu <cmd>lua require("telescope.builtin").oldfiles (
    \{search_dirs = { vim.env.INACON_DIR .. "/Kurse", vim.env.INACON_DIR .. "/Automation" } }
\)<cr>
" Find old
nno <leader>fo <cmd>Telescope oldfiles<cr>
" List color schemes
nno <leader>s <cmd>Telescope colorscheme<cr>
" List keybindings
nno <leader>k <cmd>Telescope keymaps<cr>
" List projects (project.nvim)
nno <leader>p <cmd>Telescope projects<cr>

" Tab completion in autocomplete (for default completion and compe)
ino <expr><tab> pumvisible() ? "<C-n>" : "<tab>"
" Go back using Shift+Tab instead of Ctrl+p
ino <expr><S-tab> pumvisible() ? "<C-p>" : "<S-tab>"

" LSP stuff
nno <F1> <cmd>lua require("lspsaga.hover").render_hover_doc()<cr>
nno <F2> <cmd>lua require("lspsaga.rename").rename()<cr>
nno <leader>gD <cmd>lua vim.lsp.buf.declaration()<cr>
nno gd <cmd>lua vim.lsp.buf.definition()<cr>
nno <leader>ga <cmd>lua require("lspsaga.codeaction").code_action()<cr>
nno <leader>ge <cmd>lua vim.lsp.diagnostic.goto_next()<cr>
nno <leader>gE <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>

" Format whole file
nno <leader>= <cmd>lua vim.lsp.buf.formatting()<cr>

" Open vim.init
nno <leader>rc <cmd>e $MYVIMRC<cr>
" Open plugins.lua
nno <leader>rp <cmd>e ~/.config/nvim/lua/plugins.lua<cr>

" git interactive status
nno <leader>gs <cmd>Git<cr>
" Simpler git commit than vim-fugitive
nno <leader>gc :Git commit -m ""<left>
nno <leader>gp <cmd>Git push<cr>

" Run tests
nno <leader>t <cmd>TestFile<cr>

" Reload plugins module, save and resource vim.init file
nno <leader>so <cmd>lua require("plenary.reload").reload_module("plugins")<cr>
    \<cmd>w<cr><cmd>so $MYVIMRC<cr>

" Open terminal in new window to the right
nno <leader>to <cmd>vsplit<cr><cmd>term<cr>

augroup MY_AUTO_GROUP
    autocmd!
    " Run on startup for faster keyboard movement
    autocmd VimEnter * silent !xset r rate 250 33

    " Remove trailing whitespace on save (/e to hide errors)
    autocmd BufWritePre * %s/\s\+$//e
    " Do not auto-wrap text, only comments. This does not work when set
    " as a global option (see https://vi.stackexchange.com/a/9367/37072)
    autocmd FileType * set formatoptions-=t

    autocmd BufRead *.py setlocal foldmethod=indent foldnestmax=1
    " TODO: this does not do anything yet
    autocmd BufEnter *.py PyLspReloadVenv

    " Automatically enter insert mode when in terminal mode
    " and change to current directory
    autocmd TermOpen * silent !lcd %:p:h
    autocmd TermOpen * startinsert

    " 2 spaces per tab for php files
    autocmd FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
    autocmd FileType html setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType vim setlocal shiftwidth=2 tabstop=2 expandtab
augroup end

