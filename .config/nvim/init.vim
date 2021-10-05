let $INACON_DIR = $HOME . "/Desktop/Inacon/"
let $INACON_VENV_ACTIVATE = $INACON_DIR . "inacon_env/bin/activate"
let $INACON_VENV_PYTHON = $INACON_DIR . "inacon_env/bin"

" Fixes wrong colors in Vim when using tmux
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

colorscheme edge

lua << EOF
-- Load config files from ~/.config/nvim/lua/
require("packerinit")
require("options")
EOF
runtime mappings.vim

augroup MY_AUTO_GROUP
    au!
    " Run on startup for faster keyboard movement
    au VimEnter * silent !xset r rate 210 33

    " Remove trailing whitespace on save (/e to hide errors)
    au BufWritePre * %s/\s\+$//e

    " Equalize splits after resizing
    au VimResized * wincmd =

    " Do not auto-wrap text, only comments. This does not work when set
    " as a global option (see https://vi.stackexchange.com/a/9367/37072)
    au FileType * set formatoptions-=t

    au BufRead python setlocal foldmethod=indent foldnestmax=1
    au BufEnter python PyLspReloadVenv
    " nvim-lint
    au BufEnter,BufWritePost * lua require("lint").try_lint()
    " vimtex
    au User VimtexEventInitPost VimtexCompile

    " Automatically enter insert mode when in terminal mode
    " and change to current directory
    au TermOpen * silent !lcd %:p:h
    au TermOpen * startinsert

    " 2 spaces per tab for php files
    au FileType php setlocal filetype=html shiftwidth=2 tabstop=2 expandtab
    au FileType html,vim,lua setlocal shiftwidth=2 tabstop=2 expandtab
augroup end

