" filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=80
set relativenumber
set number
set nohlsearch
set incsearch
set ignorecase
set smartcase
set splitright
set splitbelow
set scrolloff=8
set nowrap
set noswapfile

" Directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
Plug 'morhetz/gruvbox'

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'tpope/vim-fugitive'
" Displays the current branch and more at the bottom 
Plug 'vim-airline/vim-airline'

" Initialize plugin system
call plug#end()

let g:gruvbox_contrast_dark = 'medium'
colorscheme gruvbox

let mapleader = " "

nnoremap ii <Esc>
vnoremap ii <Esc>gV
onoremap ii <Esc>
cnoremap ii <C-C><Esc>
inoremap ii <Esc>`^
" Remap exiting terminal mode
tnoremap ii <C-\><C-n> 

" Remap windows movements
map <C-h> :wincmd h<CR>
map <C-j> :wincmd j<CR>
map <C-k> :wincmd k<CR>
map <C-l> :wincmd l<CR>

" Telescope remaps
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fb <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>

" Open vim.init
nnoremap <leader>rc <cmd>e $MYVIMRC<cr> 

" Git status
nnoremap <leader>gs <cmd>G<cr>

" Faster file saving and exiting
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>q <cmd>q<cr>

" Save and update (useful for vim.init file)
nnoremap <leader>so <cmd>w<cr><cmd>so %<cr>

" Format whole file
nnoremap <leader>= gg=G''zz

" Open terminal in new window to the right
nnoremap <leader>to <cmd>vsplit<cr><cmd>term<cr>
" Automatically enter insert mode when in terminal mode
" and change to current directory
autocmd TermOpen * silent! lcd %:p:h 
autocmd TermOpen * startinsert

" Change font to 'Deja Vu Sans Mono for Powerline Book' in Edit > Preferences
" (bash) or set the font in ~/.config/alacritty/alacritty.yml
" after installing powerline fonts cloning git@github.com:powerline/fonts.git
" and running ./install.sh
let g:airline_powerline_fonts = 1

" let g:airline_symbols = {}
" let g:airline_symbols.linenr = ' l:'
" let g:airline_symbols.colnr = ' c:'

" 2 spaces per tab for php files
autocmd FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab

