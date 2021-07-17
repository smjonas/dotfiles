set tabstop=4
set shiftwidth=4
set expandtab
set textwidth=80
" set cmdheight=2
" Current mode in insert mode is not necessary when using airline
set noshowmode
set timeoutlen=300
set cursorline
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
set termguicolors
" Autocomplete settings
set completeopt=menuone,noselect,preview

" Directory for plugins
call plug#begin('~/.vim/plugged')

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
Plug 'morhetz/gruvbox'
" Plug 'arcticicestudio/nord-vim'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'
" Colors for LSP error messages etc.
Plug 'folke/lsp-colors.nvim'
Plug 'glepnir/lspsaga.nvim'

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
" Displays the current branch and more at the bottom 
Plug 'vim-airline/vim-airline'
" Use nerdfont patched font
Plug 'ryanoasis/vim-devicons'

Plug 'tpope/vim-surround'
" Initialize plugin system
call plug#end()

let g:gruvbox_contrast_dark = 'medium'
colorscheme gruvbox

" LSP configuration
lua << EOF
require("lspconfig").pyright.setup{}

require("lsp-colors").setup({
    Error = "#db4b4b",
    Warning = "#e0af68",
    Information = "#0db9d7",
    Hint = "#10B981"
})

require("lspsaga").init_lsp_saga {
    error_sign = '>>',
    warn_sign = '⚠️'
}
EOF

let mapleader = " "

nnoremap ii <Esc>
vnoremap ii <Esc>gV
onoremap ii <Esc>
cnoremap ii <C-C><Esc>
inoremap ii <Esc>`^
" Remap exiting terminal mode
tnoremap ii <C-\><C-n> 

" Faster file saving and exiting
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>q <cmd>q<cr>
nnoremap <leader>! <cmd>q!<cr>

" Insert new line below and above without entering insert mode
nnoremap oo o<esc>0"_D
nnoremap OO O<esc>0"_D

" Remap windows movements
map <C-h> <cmd>wincmd h<CR>
map <C-j> <cmd>wincmd j<CR>
map <C-k> <cmd>wincmd k<CR>
map <C-l> <cmd>wincmd l<CR>
nnoremap <C-n> <cmd>NERDTreeToggle<cr>

" Telescope remaps
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
nnoremap <leader>fb <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>

" Tab completion in autocomplete
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" LSP stuff
nnoremap <F2> <cmd>lua require("lspsaga.rename").rename()<cr>
nnoremap <leader>gD <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap <leader>gd <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <leader>ga <cmd>lua require("lspsaga.codeaction").code_action()<cr>
nnoremap <leader>ge <cmd>lua vim.lsp.diagnostic.goto_next()<cr> 
nnoremap <leader>gE <cmd>lua vim.lsp.diagnostic.goto_prev()<cr> 

" Format whole file
nnoremap <leader>= <cmd>lua vim.lsp.buf.formatting()<cr>

" Open vim.init
nnoremap <leader>rc <cmd>e $MYVIMRC<cr> 
" Open vim.init and delete unsaved changes
nnoremap <leader>rc! <cmd>e!<cr> <cmd>e $MYVIMRC<cr> 

" Git status
nnoremap <leader>gs <cmd>G<cr>

" Save and update (useful for vim.init file)
nnoremap <leader>so <cmd>w<cr><cmd>so %<cr>

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

