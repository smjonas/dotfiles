let $INACON_DIR = $HOME . "/Desktop/Inacon/"
let $INACON_VENV_ACTIVATE = $INACON_DIR . "inacon_env/bin/activate"
let $INACON_VENV_PYTHON = $INACON_DIR . "inacon_env/bin"

" Fixes wrong colors in Vim when using tmux
if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

lua << EOF
-- Load config files from ~/.config/nvim/lua/
require("packerinit")
require("options")
EOF
runtime mappings.vim

colorscheme edge

augroup my_auto_group
  autocmd!
  " Run on startup for faster keyboard movement
  autocmd VimEnter * silent !xset r rate 210 33

  " Remove trailing whitespace on save (/e to hide errors)
  autocmd BufWritePre * %s/\s\+$//e

  " Equalize splits after resizing
  autocmd VimResized * wincmd =

  " Do not autocmdto-wrap text, only comments. This somehow does not work when set
  " as a global option (see https://vi.stackexchange.com/a/9367/37072)
  autocmd FileType * set formatoptions-=t

  " nvim-lint
  autocmd BufEnter,BufWritePost * lua require("lint").try_lint()
  " vimtex
  autocmd User VimtexEventInitPost VimtexCompile

  " autocmdtomatically enter insert mode when in terminal mode
  " and change to current directory
  autocmd TermOpen * silent !lcd %:p:h
  autocmd TermOpen * startinsert

  " 2 spaces per tab for php files
  " autocmd FileType php setlocal filetype=html shiftwidth=2 tabstop=2
augroup end

augroup packer_user_config
  autocmd!
  autocmd BufWritePost packerinit.lua PackerCompile
augroup end

