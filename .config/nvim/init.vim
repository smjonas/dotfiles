" set cmdheight=2
" Use system clipboard
set clipboard^=unnamed,unnamedplus
" Autocomplete settings
set completeopt=menuone,noselect,preview
set cursorline
set expandtab
set ignorecase
" Show replacement results while typing command
set inccommand=nosplit
set incsearch
set nohlsearch
" Current mode in insert mode is not necessary when using status line plugin
set noshowmode
set noswapfile
set nowrap
set number
set relativenumber
set scrolloff=8
set shiftwidth=4
set smartcase
set splitbelow splitright
set tabstop=4
set textwidth=90
set timeoutlen=300
set undodir=~/.vim/nvim-undo-dir
set undofile

" Fixes wrong colors in Vim when using tmux (don't know if this is still needed)
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set background=dark
set t_Co=256

" Directory for plugins
call plug#begin('~/.vim/plugged')
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': '0.5-compat', 'do': ':TSUpdate' }
Plug 'sainnhe/gruvbox-material'
  let g:gruvbox_material_palette = "mix"
  let g:gruvbox_material_background = "medium"

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-compe'

"Colors for LSP error messages etc.
Plug 'folke/lsp-colors.nvim'
Plug 'glepnir/lspsaga.nvim'

" Telescope stuff
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Fern and fern plugins
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/fern.vim'
  let g:fern#renderer = "nerdfont"
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/glyph-palette.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'tpope/vim-fugitive'

Plug 'hoob3rt/lualine.nvim', {'commit': 'dc2c711'}
" Change font to Powerline compatible font in Edit > Preferences (bash)
" or set the font in ~/.config/alacritty/alacritty.yml
" after installing by cloning git@github.com:powerline/fonts.git
" and running ./install.sh
Plug 'ryanoasis/vim-devicons'

Plug 'wellle/targets.vim'
Plug 'windwp/nvim-autopairs'
Plug 'b3nj5m1n/kommentary'

Plug 'arp242/undofile_warn.vim'

Plug 'tpope/vim-surround'
" Allows to repeat vim surround commands, e.g. cs'"
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-obsession'

" Initialize plugin system
call plug#end()

colorscheme gruvbox-material

" LSP configuration
lua << EOF
require("lspconfig").pyright.setup{}
require("lspconfig").html.setup{}
require("lspconfig").vimls.setup{}

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

require("telescope").setup()
require("telescope").load_extension("fzf")

require("compe").setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = false;
    ultisnips = true;
    luasnip = true;
  };
}

function obsessionStatus()
   return vim.fn.ObsessionStatus("tracking", "paused")
end

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = { {'filename', full_path = true, symbols = {modified = '[*]'} } },
    lualine_x = {'fileformat', 'filetype'},
    lualine_y = {'location', 'progress'},
    lualine_z = {'obsessionStatus()'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {'filename', symbols = {modified = '[*]'} } },
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

require("nvim-autopairs").setup()

require("nvim-autopairs.completion.compe").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true -- it will auto insert `(` after selecting function or method item
})
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
inoremap <C-h> <C-o>h
inoremap <C-l> <C-o>a
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k

" Movement when wrap option is enabled
nnoremap j gj
nnoremap k gk

" Moving lines (==) for correct indentation
nnoremap <silent> <C-k> :move-2<cr>==
nnoremap <silent> <C-j> :move+<cr>==
nnoremap <silent> <C-l> >>
nnoremap <silent> <C-h> <<
xnoremap <silent> <C-k> :move-2<cr>gv
xnoremap <silent> <C-j> :move'>+<cr>gv
xnoremap <silent> <C-h> <gv
xnoremap <silent> <C-l> >gv

" Insert new line below and above without entering insert mode
nnoremap <space>o o<esc>0"_D
nnoremap <space>O O<esc>0"_D

" Line break from within normal mode
nnoremap <cr> myi<cr><esc>g`y

" Yank to end of line
nnoremap Y y$

" Keep it centered (zv to open folds if necessary)
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J J$

" Undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u

" Jumplist mutations (O works as expected)
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Search and replace
nnoremap <leader><F2> :%s///gc<left><left><left><left>

" Circular window movements
nnoremap <tab> <c-w>w
nnoremap <s-tab> <c-w>W
nnoremap <c-n> <cmd>:Fern . -drawer -toggle<cr>

" Faster file saving and exiting
nnoremap <leader>w <cmd>w<cr>
nnoremap <leader>q <cmd>q<cr>
nnoremap <leader>! <cmd>q!<cr>

lua << EOF
function _G.yanked_contains_eol()
    local reg = vim.fn.getreg('0')
    local caret_j = vim.api.nvim_replace_termcodes("<C-j>", true, true, true)
    -- If we do not have an eol character in reg, matchstr will return an empty string
    return vim.fn.matchstr(reg, '[^' .. caret_j .. ']' .. caret_j) ~= ""
end

function _G.cursor_on_last_char()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- Make column index 1-based
    local col = cursor_pos[2] + 1
    local row_len = #vim.api.nvim_get_current_line()
    return row_len == 0 or row_len == col
end
EOF

" Paste contents of empty register (last yank) after the current
" position (without new line character):

" mx - store cursor position in mark x
" p - paste last yanked contents to line below
" "xd$ - delete everything until the last character into register x
" g`x - restore cursor position to mark x (g to not change jumplist)
nnoremap <expr><c-x> v:lua.yanked_contains_eol()
    \ ? 'mxp"xd$g`xJ`x"_d$"xp'
    \ : v:lua.cursor_on_last_char()
        \ ? 'a<space><esc>"_d$p'
        \ : 'l"_d$p'

" Compe remaps
inoremap <silent><expr> <c-n> compe#complete()
inoremap <silent><expr> <cr> compe#confirm('<CR>')

" Telescope remaps
" [Find files]
nnoremap <leader>ff <cmd>Telescope find_files hidden=true<cr>
" [Find Inacon]
nnoremap <leader>fi <cmd>lua require("telescope.builtin").find_files (
    \{search_dirs = { "~/Desktop/Inacon/Kurse", "~/Desktop/Inacon/Automation" }}
\)<cr>
" [Find current]: files and folders in current directory
nnoremap <leader>fc <cmd>Telescope file_browser hidden=true<cr>
" [Find search]
nnoremap <leader>fs <cmd>Telescope current_buffer_fuzzy_find<cr>
" [Find old]
nnoremap <leader>fo <cmd>Telescope oldfiles<cr>

" Tab completion in autocomplete (for default completion and compe)
inoremap <expr><tab> pumvisible() ? "<c-n>" : "<tab>"
" Go back using Shift+Tab instead of Ctrl+p
inoremap <expr><s-tab> pumvisible() ? "<c-p>" : "<s-tab>"

" LSP stuff
nnoremap <F1> <cmd>lua require("lspsaga.hover").render_hover_doc()<cr>
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

augroup AUTO_CLEAR
  autocmd!
augroup end

" Run on startup for faster keyboard movement
autocmd VimEnter * silent !xset r rate 250 33

" Remove trailing whitespace on save (/e to hide errors)
autocmd BufWritePre * %s/\s\+$//e
" Do not auto-wrap text, only comments. This does not work when set
" as a global option (see https://vi.stackexchange.com/a/9367/37072)
autocmd FileType * set formatoptions-=t

" Automatically enter insert mode when in terminal mode
" and change to current directory
autocmd TermOpen * silent !lcd %:p:h
autocmd TermOpen * startinsert

" 2 spaces per tab for php files
autocmd FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
autocmd FileType html setlocal shiftwidth=2 tabstop=2 expandtab
autocmd FileType vim setlocal shiftwidth=2 tabstop=2 expandtab

