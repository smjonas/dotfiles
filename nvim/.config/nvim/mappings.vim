let mapleader = " "

nnoremap ij <Esc>
xnoremap ij <Esc>gV
onoremap ij <Esc>
inoremap ij <Esc>`^
cno ij <C-C><Esc>

" Remap exiting terminal mode
tno ij <C-\><C-n>

lua << EOF
-- Basic movement in insert mode
local map = vim.keymap.set
map("i", KB["insert.left"], "<left>")
map("i", KB["insert.right"], "<right>")
map("i", KB["insert.up"], "<up>")
map("i", KB["insert.down"], "<down>")
EOF

" Movement when wrap option is enabled
nnoremap j gj
nnoremap k gk

" Faster moving to start / end of line
nnoremap H ^
nnoremap L $

" Insert new line below and above without entering insert mode
nnoremap <leader>o o<Esc>0"_D
nnoremap <leader>O O<Esc>0"_D

" Line break in normal mode
nnoremap <cr> mxi<cr><Esc>g`x

" Use black hole register
nnoremap <leader>d "_d
nnoremap <leader>D "_D
nnoremap c "_c
nnoremap C "_C
nnoremap x "_x
" To use default behavior of x
nnoremap <leader>z x

nnoremap J J$

" Enable copying to system clipboard; simply changing vim.o.clipboard to include
" unnamedplus would paste from system clipboard with p which I want to use <leader>p for instead
nnoremap y "+y
xnoremap y "+y
nnoremap Y "+y$
xnoremap Y "+y$

" Yank entire buffer
nmap <leader>Y mxggyG`xzz

" Insert from clipboard in paste mode
nnoremap <leader>p <cmd>set paste<cr>a<C-r>+<Esc><cmd>set nopaste<cr>
inoremap <A-b> <cmd>set paste<cr><C-r>+<cmd>set nopaste<cr>
xnoremap <leader>p <cmd>set paste<cr>"+p<cmd>set nopaste<cr>

" Remove once #19354 is merged
xnoremap p P | xnoremap P p

" Visually select last pasted text
nnoremap gp `[v`]

function! Sort(...) abort
  '[,']sort
  call setpos('.', getpos("''"))
endfunction
" Sort operator (remove once #19354 is merged)
nnoremap gs m'<Cmd>set operatorfunc=Sort<CR>g@
xnoremap gs :sort<CR>

" Makes it harder to accidentally record a macro
nnoremap Q q
nnoremap q nop
" Go to previous / next buffers
nnoremap qj <cmd>bp<cr>zz
nnoremap qk <cmd>bn<cr>zz

" Do not move by accident
nnoremap <space> <nop>

" Go to previous file and center
nnoremap  <C-^> <C-^>zz
nmap <bs>  <C-^>

" Keep it centered (zv to open folds if necessary)
nnoremap n nzzzv
nnoremap N Nzzzv

" More centering
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap { {zz
nnoremap } }zz
nnoremap * *zz
nnoremap # #zz

nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz
nnoremap <C-o> <C-o>zz
" Move forwards in jump list
nnoremap <C-e> <C-i>zz

" Easier incrementing / decrementing
nnoremap + g<C-a>
nnoremap - g<C-x>
xnoremap + g<C-a>
xnoremap - g<C-x>

" Repeat last command in visual mode
xnoremap . :norm .<cr>

" Better undo break points
" Leave uncommented until #20248 is fixed (causes issues with live-command)
" inoremap , ,<C-g>u
" inoremap . .<C-g>u
" inoremap _ _<C-g>u

" Jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Copy word from line above (word-wise <C-y>)
inoremap <expr> <C-z> pumvisible() ? "\<C-y>" : matchstr(getline(line('.')-1), '\%' . virtcol('.') . 'v\%(\k\+\\|.\)')

" Better mappings to go back to a mark
nnoremap ' `
nnoremap ` '

" Search and replace
nnoremap <leader>s :%s///gc<left><left><left><left>
xnoremap s :s/\%V//g<left><left><left>

" Quickfix list mappings
function! ToggleQfList()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
  else
    cclose
  endif
endfunction
nnoremap <silent> <C-q> <cmd>call ToggleQfList()<cr>
lua << EOF
local map = vim.keymap.set
map("n", KB["quickfix.prev"], "<cmd>cprev<cr>")
map("n", KB["quickfix.next"], "<cmd>cnext<cr>")

-- Moving between windows (from Ben Frain's talk at NeovimConf 2022)
for i = 1, 6 do
  local lhs = "<leader>" .. i
  local rhs = i .. "<c-w>w"
  map("n", lhs, rhs, { desc = "Move to window " .. i })
end
EOF

" Fallback to use with few windows (imo less cognitive overhead in that case)
nnoremap <Tab> <c-w>w
nnoremap <S-Tab> <c-w>W

" Open new horizontal split (consistent with Ctrl-W + v)
nnoremap <C-w><C-h> <cmd>split<cr>
" Split the alternate buffer vertically; don't know if this is a Vim bug or not
" but this is a workaround since somehow 'splitright' is not respected by Vim
nnoremap <C-w><C-^> <C-w><C-^><C-w>t<C-w>H

" Faster file saving and exiting
nnoremap <leader>w <cmd>update<cr>
nnoremap <leader>q <cmd>q<cr>

" Open current file in browser
nnoremap <silent> <F3> <cmd>!firefox %<cr>

let nvim_config_root = stdpath('config')
" Edit lua config files
lua << EOF
local nvim_config_root = vim.fn.stdpath("config")
vim.keymap.set("n", KB["edit.init"], ("<cmd>e %s/init.lua<cr>"):format(nvim_config_root), { desc="Edit init.lua" })
EOF
nnoremap <leader>rp <cmd>execute 'e ' . nvim_config_root . '/lua/plugins/init.lua'<cr>
nnoremap <leader>ro <cmd>execute 'e ' . nvim_config_root . '/lua/options.lua'<cr>
nnoremap <leader>rm <cmd>execute 'e ' . nvim_config_root . '/mappings.vim'<cr>

" Reload packerinit file, save and resource vim files (except init.vim)
" This is used in .vimrc to reload the config when a file in the config folder was saved.
nnoremap <Plug>reload_my_config <cmd>luafile ~/.config/nvim/lua/packerinit.lua<cr>
      \<cmd>luafile ~/.config/nvim/lua/options.lua<cr>
      \<cmd>w<cr><cmd>runtime mappings.vim<cr>
      \<cmd>PackerCompile<cr>

" Launch current buffer in new kitty tab
" (requires the current terminal emulator instance to be started with kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty)
nnoremap <F1> <cmd>silent !kitty @ launch --type=tab --cwd=current --location=neighbor nvim %<cr>
nnoremap <F2> <cmd>ReloadConfig<cr>

" Open terminal in new window to the right
nnoremap <leader>to <cmd>vsplit<cr><cmd>term<cr>
