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
set scrolloff=8
set shiftround
set shiftwidth=4
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
  let g:onedark_style = 'warmer'

Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
  let g:coq_settings = { 'auto_start': v:true }
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

nnoremap ii <Esc>
vnoremap ii <Esc>gV
onoremap ii <Esc>
inoremap ii <Esc>`^
cnoremap ii <C-C><Esc>
" Remap exiting terminal mode
tnoremap ii <C-\><C-n>

" Basic movement in insert mode
inoremap <C-h> <left>
inoremap <C-l> <right>
inoremap <C-j> <down>
inoremap <C-k> <up>

" Movement when wrap option is enabled
nnoremap j gj
nnoremap k gk

" Faster moving to start / end of line
nnoremap H ^
nnoremap L $

" Moving lines (==) for correct indentation
nnoremap <silent> <C-k> :move-2<cr>==
nnoremap <silent> <C-j> :move+<cr>==
nnoremap <silent> <C-l> >>
nnoremap <silent> <C-h> <<
xnoremap <silent> <C-k> :move-2<cr>gv
xnoremap <silent> <C-j> :move'>+<cr>gv
xnoremap <silent> <C-h> <gv
xnoremap <silent> <C-l> >gv

" Sideways text objects to select arguments
omap <silent> aa <Plug>SidewaysArgumentTextobjA
xmap <silent> aa <Plug>SidewaysArgumentTextobjA
omap <silent> ia <Plug>SidewaysArgumentTextobjI
xmap <silent> ia <Plug>SidewaysArgumentTextobjI

" Swap function arguments
nnoremap <M-h> <cmd>SidewaysLeft<cr>
nnoremap <M-l> <cmd>SidewaysRight<cr>

" Insert new line below and above without entering insert mode
nnoremap <leader>o o<Esc>0"_D
nnoremap <leader>O O<Esc>0"_D

" Use black hole register for deleting
nnoremap <leader>d "_d
nnoremap <leader>D "_D

" Line break from normal mode
nnoremap <cr> myi<cr><Esc>g`y

" Yank to end of line
nnoremap Y y$

" Avoid accidentally recording a macro
nnoremap q <nop>
nnoremap <leader>q q

" Do not move by accident
nnoremap <space> <nop>

" Keep it centered (zv to open folds if necessary)
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J J$

" Center on buffer change
nnoremap <c-6> <c-6>zz

" Undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap _ _<c-g>u

" Jumplist mutations (O works as expected)
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Search and replace
nnoremap <leader><F2> :%s///gc<left><left><left><left>

" Circular window movements
nnoremap <tab> <c-w>w
nnoremap <S-tab> <c-w>W

nnoremap <c-n> <cmd>:Fern %:h -drawer -toggle<cr>
" Use . to go up a directory
" nmap <buffer><expr> . <Plug>(fern-action-leave)

" nnoremap <c-n> <cmd>30 Lexplore %:p:h<cr>
"     let g:netrw_liststyle = 3
"     let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

" Faster file saving and exiting
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>q <cmd>q<cr>
nnoremap <leader>! <cmd>q!<cr>

" Compe remaps
" inoremap <silent><expr> <c-n> compe#complete()
" inoremap <silent><expr> <cr> compe#confirm('<CR>')

" -- Telescope remaps --
" Find files
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
" Find buffers
nnoremap <leader>fb <cmd>Telescope buffers sort_mru=true<cr>
" Find Inacon
nnoremap <leader>fi <cmd>lua require("telescope.builtin").find_files (
    \{search_dirs = { vim.env.INACON_DIR .. "/Kurse", vim.env.INACON_DIR .. "/Automation" } }
\)<cr>
" Find old in Inacon
nnoremap <leader>fu <cmd>lua require("telescope.builtin").oldfiles (
    \{search_dirs = { vim.env.INACON_DIR .. "/Kurse", vim.env.INACON_DIR .. "/Automation" } }
\)<cr>
" Find old
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>
" List color schemes
nnoremap <leader>s <cmd>Telescope colorscheme<cr>
" List keybindings
nnoremap <leader>k <cmd>Telescope keymaps<cr>
" List projects (project.nvim)
nnoremap <leader>p <cmd>Telescope projects<cr>

" Tab completion in autocomplete (for default completion and compe)
inoremap <expr><tab> pumvisible() ? "<c-n>" : "<tab>"
" Go back using Shift+Tab instead of Ctrl+p
inoremap <expr><S-tab> pumvisible() ? "<c-p>" : "<S-tab>"

" LSP stuff
nnoremap <F1> <cmd>lua require("lspsaga.hover").render_hover_doc()<cr>
nnoremap <F2> <cmd>lua require("lspsaga.rename").rename()<cr>
nnoremap <leader>gD <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <leader>ga <cmd>lua require("lspsaga.codeaction").code_action()<cr>
nnoremap <leader>ge <cmd>lua vim.lsp.diagnostic.goto_next()<cr>
nnoremap <leader>gE <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>

" Format whole file
nnoremap <leader>= <cmd>lua vim.lsp.buf.formatting()<cr>

" Open vim.init
nnoremap <leader>rc <cmd>e $MYVIMRC<cr>
" Open plugins.lua
nnoremap <leader>rp <cmd>e ~/.config/nvim/lua/plugins.lua<cr>

" git interactive status
nnoremap <leader>gs <cmd>Git<cr>
" Simpler git commit than vim-fugitive
nnoremap <leader>gc :Git commit -m ""<left>
nnoremap <leader>gp <cmd>Git push<cr>

" Run tests
nnoremap <leader>t <cmd>TestFile<cr>

" Reload plugins module, save and resource vim.init file
nnoremap <leader>so <cmd>lua require("plenary.reload").reload_module("plugins")<cr>
    \<cmd>w<cr><cmd>so $MYVIMRC<cr>

" Open terminal in new window to the right
nnoremap <leader>to <cmd>vsplit<cr><cmd>term<cr>

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
    " autocmd BufRead *.py PyLspReloadVenv

    " Automatically enter insert mode when in terminal mode
    " and change to current directory
    autocmd TermOpen * silent !lcd %:p:h
    autocmd TermOpen * startinsert

    " 2 spaces per tab for php files
    autocmd FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
    autocmd FileType html setlocal shiftwidth=2 tabstop=2 expandtab
    autocmd FileType vim setlocal shiftwidth=2 tabstop=2 expandtab
augroup end

