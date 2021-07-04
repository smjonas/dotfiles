set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set relativenumber
set number
set nohlsearch
set incsearch
set ignorecase
set smartcase
set scrolloff=8

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
inoremap <Leader><Tab> <Tab>

nnoremap <leader>ff <cmd>Telescope find_files<cr>

" Open vim.init
nnoremap <leader>rc <cmd>e ~/.config/nvim/init.vim<cr> 
