set tw=80
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
inoremap <Leader><Tab> <Tab>

" Remap windows movements
map <leader>h :wincmd h<CR>
map <leader>j :wincmd j<CR>
map <leader>k :wincmd k<CR>
map <leader>l :wincmd l<CR>

nnoremap <leader>ff <cmd>Telescope find_files<cr>

" Open vim.init
nnoremap <leader>rc <cmd>e ~/.config/nvim/init.vim<cr> 

" git status
nnoremap <leader>gs <cmd>G<cr>

" Change font to 'Deja Vu Sans Mono for Powerline Book' in Edit > Preferences
" (bash) or set the font in ~/.config/alacritty/alacritty.yml
" after installing powerline fonts cloning git@github.com:powerline/fonts.git
" and running ./install.sh
let g:airline_powerline_fonts = 1

"let g:airline_symbols = {}
"let g:airline_symbols.linenr = ' l:'
"let g:airline_symbols.colnr = ' c:'

