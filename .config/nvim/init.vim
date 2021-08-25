let $INACON_DIR = $HOME . "/Desktop/Inacon/"
let $INACON_VENV_ACTIVATE = $INACON_DIR . "inacon_env/bin/activate"
let $INACON_VENV_PYTHON = $INACON_DIR . "inacon_env/bin"

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
Plug 'glepnir/lspsaga.nvim'
" Modified version of mfussenegger/nvim-lint
Plug 'jonasstr/nvim-lint'

Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

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

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
" Allows to repeat vim surround commands, e.g. cs'"
Plug 'tpope/vim-repeat'
" Plug 'rmagatti/auto-session'

" Swap function arguments using Alt + arrow keys
Plug 'AndrewRadev/sideways.vim'
Plug 'ggandor/lightspeed.nvim'

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
-- Load config files from ~/.config/nvim/lua/
require("options")
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

" Avoid accidentally recording a macro
nno q <nop>
nno Q q

" Do not move by accident
nno <space> <nop>

" Keep it centered (zv to open folds if necessary)
nno n nzzzv
nno N Nzzzv
nno g; g;zz
nno g, g,zz

" Center on buffer change
nno <C-^> <C-^>zz
nno <bs> <C-^>

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

nno <C-n> <cmd>Fern %:h -drawer -toggle<cr>
" Use . to go up a directory
" nmap <buffer><expr> . <Plug>(fern-action-leave)

" Faster file saving and exiting
nno <leader>w <cmd>w<cr>
nno <leader>q <cmd>q<cr>

" Coq remaps
ino <c-a> <cmd>lua COQnav_mark()<cr>
" Tab completion in autocomplete (for default completion and coq)
ino <expr><tab> pumvisible() ? "<C-n>" : "<tab>"
" Go back using Shift+Tab instead of Ctrl+p
ino <expr><S-tab> pumvisible() ? "<C-p>" : "<S-tab>"

" -- Telescope remaps --
nno <leader>ff <cmd>lua require("plugins").find_files()<cr>
nno <leader>fg <cmd>lua require("plugins").live_grep()<cr>
" Requires ripgrep to be installed (sudo apt install ripgrep)
nno <leader>fb <cmd>lua require("plugins").find_buffers()<cr>
nno <leader>fi <cmd>lua require("plugins").find_inacon()<cr>
nno <leader>fu <cmd>lua require("plugins").find_old_inacon()<cr>
" Find old
nno <leader>fo <cmd>Telescope oldfiles<cr>
nno <leader>h <cmd>Telescope help_tags<cr>
nno <leader>s <cmd>Telescope colorscheme<cr>
nno <leader>k <cmd>Telescope keymaps<cr>
" List projects (project.nvim)
nno <leader>p <cmd>Telescope projects<cr>
nno <leader>u <cmd>PlugClean!<cr><cmd>PlugUpdate<cr>

" LSP stuff
nno <F1> <cmd>lua require("lspsaga.hover").render_hover_doc()<cr>
nno <F2> <cmd>lua require("lspsaga.rename").rename()<cr>
nno <leader>gD <cmd>lua vim.lsp.buf.declaration()<cr>
nno gd <cmd>lua vim.lsp.buf.definition()<cr>
nno <leader>ga <cmd>lua require("lspsaga.codeaction").code_action()<cr>
nno gr <cmd>lua vim.lsp.diagnostic.goto_prev()<cr>
nno gh <cmd>lua vim.lsp.diagnostic.goto_next()<cr>

" Format whole file
nno <leader>= <cmd>lua vim.lsp.buf.formatting()<cr>

" Open vim.init
nno <leader>rc <cmd>e $MYVIMRC<cr>
nno <leader>Rc <cmd>e! $MYVIMRC<cr>
" Open lua config files
nno <leader>rp <cmd>e ~/.config/nvim/lua/plugins.lua<cr>
nno <leader>ro <cmd>e ~/.config/nvim/lua/options.lua<cr>

" git interactive status
nno <leader>gs <cmd>Git<cr>
" Simpler git commit than vim-fugitive
nno <leader>gc :Git commit -m ""<left>
nno <leader>gp <cmd>Git push<cr>

" Run tests
nno <leader>t <cmd>TestFile<cr>

" Reload plugins module, save and resource vim.init file
nno <leader>so <cmd>lua require("plenary.reload").reload_module("plugins")<cr>
    \<cmd>lua require("plenary.reload").reload_module("options")<cr>
    \<cmd>w<cr><cmd>so $MYVIMRC<cr>

" Open terminal in new window to the right
nno <leader>to <cmd>vsplit<cr><cmd>term<cr>

augroup MY_AUTO_GROUP
    au!
    " Run on startup for faster keyboard movement
    au VimEnter * silent !xset r rate 250 33

    " Remove trailing whitespace on save (/e to hide errors)
    au BufWritePre * %s/\s\+$//e
    " Do not auto-wrap text, only comments. This does not work when set
    " as a global option (see https://vi.stackexchange.com/a/9367/37072)
    au FileType * set formatoptions-=t

    au BufRead python setlocal foldmethod=indent foldnestmax=1
    au BufEnter python PyLspReloadVenv
    " nvim-lint
    au BufEnter,BufWritePost * lua require("lint").try_lint()

    " Automatically enter insert mode when in terminal mode
    " and change to current directory
    au TermOpen * silent !lcd %:p:h
    au TermOpen * startinsert

    " 2 spaces per tab for php files
    au FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
    au FileType html,vim setlocal shiftwidth=2 tabstop=2 expandtab
augroup end

