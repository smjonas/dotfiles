local o = vim.opt

-- Leader key
vim.g.mapleader = " "

-- Basic settings
o.clipboard:append("unnamed")
o.ignorecase = true
o.incsearch = true
o.scrolloff = 2
o.sidescroll = 1
o.timeoutlen = 250
o.undolevels = 1000
vim.opt = o

local map = vim.keymap.set
-- Remap Esc in insert mode
map("i", "ij", "<Esc>")
map("n", "<leader>w", "<cmd>w<cr>")

-- Faster move to start/end of line
map("n", "H", "^")
map("n", "L", "$")

-- Movement in insert mode
map("i", "<A-h>", "<Left>")
map("i", "<A-j>", "<Down>")
map("i", "<A-k>", "<Up>")
map("i", "<A-l>", "<Right>")

-- Moving lines vertically
map({ "n", "x" }, "<A-h>", "<cmd><<cr>")
map({ "n", "x" }, "<A-l>", "<cmd>><cr>")
-- and horizontally
map({ "n", "x" }, "<A-j>", "<Esc>:call MoveVisualSelection('Down')<CR>")
map({ "n", "x" }, "<A-k>", "<Esc>:call MoveVisualSelection('Up')<CR>")

-- Insert new line without entering insert mode
map("n", "<leader>o", 'o<Esc>0"_D')
map("n", "<leader>O", 'O<Esc>0"_D')

-- Use black hole register to delete/change without yanking
map("n", "dd", '"_dd')
map("n", "D", '"_D')
map("n", "cc", '"_cc')
map("n", "C", '"_C')
map("n", "x", '"_x')
-- To use default behavior of x
map("n", "<leader>z", "x")

-- Go to previous file
map("n", "<bs>", "<C-6>zz")

-- Unmap space
map("n", "<space>", "")

-- IDE actions
-- Search and replace
map("n", "<leader>s", "<cmd>lua require('vscode').action('editor.action.startFindReplaceAction')<CR>")
-- Go to prev / next error
map("n", "<C-j>", "<cmd>lua require('vscode').action('editor.action.marker.prevInFiles')<CR>")
map("n", "<C-k>", "<cmd>lua require('vscode').action('editor.action.marker.nextInFiles')<CR>")
-- Rename symbol
map("n", "<leader>rn", "<cmd>lua require('vscode').action('editor.action.rename')<CR>")
-- Find in files
map("n", "<leader>fg", "<cmd>lua require('vscode').action('workbench.action.findInFiles')<CR>")
-- Find file to open
map("n", "<leader>fp", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
-- View open files
-- map("n", "<leader>fo", "<cmd>lua require('vscode').action('workbench.action.files.openFile')<CR>")

-- Centering on search and jumps
-- TODO
-- map("n", "{", "{zz")
-- map("n", "}", "}zz")
-- map("n", "*", "*zz")
-- map("n", "#", "#zz")
-- map("n", "<C-u>", "<C-u>zz")
-- map("n", "<C-d>", "<C-d>zz")
-- map("n", "<C-o>", "<C-o>zz")
-- map("n", "<C-i>", "<C-i>zz")

-- Alias for "
-- map("o", "iq", 'i"', { expr = true })
-- map("o", "aq", 'a"', { expr = true })

vim.cmd[[
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank { timeout = 135 }
augroup END

" Source: https://github.com/vscode-neovim/vscode-neovim/issues/200#issuecomment-1245990562
function! MoveVisualSelection(direction)
  let markStartLine = "'<"
  let markEndLine =   "'>"
  let startLine = getpos(markStartLine)[1]
  let endLine = getpos(markEndLine)[1]
  let removeVsCodeSelectionAfterCommand = 1
  let linecount = getbufinfo('%')[0].linecount
  if (a:direction == "Up" && startLine == 1) || (a:direction == "Down" && endLine == linecount)
      let newStart = startLine
      let newEnd = endLine
  else
    call VSCodeCallRange('editor.action.moveLines'. a:direction . 'Action', startLine, endLine, removeVsCodeSelectionAfterCommand )
    if a:direction == "Up"
      let newStart = startLine - 1
      let newEnd = endLine - 1
    else
      let newStart = startLine + 1
      let newEnd = endLine + 1
    endif
  endif
  let newVis = "normal!" . newStart . "GV". newEnd . "G"
  execute newVis
endfunction
]]
