let $INACON_DIR = $HOME . '/Desktop/Inacon/'
let $INACON_VENV_ACTIVATE = $INACON_DIR . 'inacon_env/bin/activate'
let $INACON_VENV_PYTHON = $INACON_DIR . 'inacon_env/bin'

" Fixes wrong terminal colors when using tmux
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" Make <C-i> and <C-tab> map to different actions
if $TERM == "xterm-kitty"
  autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif
  autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif
endif

lua << EOF
-- Load config files from ~/.config/nvim/lua/
require("utils") -- load global util functions
require("options")
require("packerinit")
require("theme").init()
EOF

runtime mappings.vim

augroup my_auto_group
  autocmd!

  " Run on startup for faster keyboard movement
  autocmd VimEnter * silent !xset r rate 205 35

  " Remove trailing whitespace on save (/e to hide errors)
  autocmd BufWritePre * %s/\s\+$//e

  " Enable highlight on yank
  autocmd TextYankPost * silent! lua vim.highlight.on_yank { timeout = 130 }

  " Equalize splits after resizing
  autocmd VimResized * wincmd =

  " Open help files in a vertical split
  autocmd FileType help wincmd L

  " Do not wrap text, only comments. This somehow does not work when set
  " as a global option (see https://vi.stackexchange.com/a/9366/37072)
  autocmd FileType * set formatoptions-=t

  " Automatically enter insert mode when in terminal mode
  " and change to current directory
  autocmd TermOpen * silent !lcd %:p:h
  autocmd TermOpen * startinsert
augroup end

function ReloadConfig()
  :luafile ~/.config/nvim/lua/packerinit.lua
  :luafile ~/.config/nvim/lua/colorschemes.lua
  :luafile ~/.config/nvim/lua/options.lua
  :runtime mappings.vim
  :PackerCompile
endfunction

augroup packer_user_config
  autocmd!
  autocmd BufWritePost */nvim/*.lua call ReloadConfig()
augroup end

