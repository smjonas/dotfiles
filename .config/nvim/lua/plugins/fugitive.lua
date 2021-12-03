
local map = require('utils').map
map('n', '<leader>gs', '<cmd>Git<cr>')
map('n', '<leader>gp', '<cmd>Git push<cr>')

local M = {}

-- This is a hacky way to trick fugitive into using yadm instead of git from all buffers.

-- First, replace the implementation of the FugitiveGitDir function to always return the
-- location of the .yadm git folder regardless of the buffer number.
-- This avoids "file does not belong to a Git repository" messages.
-- After running the yadm command, switch back to the original implementation again.
function M.yadm_command(cmd)

  vim.cmd([[
  function! FugitiveGitDir(...) abort
    return $HOME . "/.config/yadm/repo.git"
  endfunction
  ]])

  vim.g["fugitive_git_executable"] = "yadm"
  vim.cmd("Git " .. (cmd or ""))
  vim.g["fugitive_git_executable"] = "git"

  vim.cmd([[
  if exists('+shellslash')
      function! s:Slash(path) abort
        return tr(a:path, '\', '/')
      endfunction
    else
      function! s:Slash(path) abort
        return a:path
    endfunction
  endif

  let s:bad_git_dir = '/$\|^fugitive:'

  function! FugitiveGitDir(...) abort
    if v:version < 703
      return ''
    elseif !a:0 || type(a:1) == type(0) && a:1 < 0 || a:1 is# get(v:, 'true', -1)
      if exists('g:fugitive_event')
        return g:fugitive_event
      endif
      let dir = get(b:, 'git_dir', '')
      if empty(dir) && (empty(bufname('')) || &buftype =~# '^\%(nofile\|acwrite\|quickfix\|terminal\|prompt\)$')
        return FugitiveExtractGitDir(getcwd())
      elseif (!exists('b:git_dir') || b:git_dir =~# s:bad_git_dir) && empty(&buftype)
        let b:git_dir = FugitiveExtractGitDir(expand('%:p'))
        return b:git_dir
      endif
      return dir =~# s:bad_git_dir ? '' : dir
    elseif type(a:1) == type(0) && a:1 isnot# 0
      if a:1 == bufnr('') && (!exists('b:git_dir') || b:git_dir =~# s:bad_git_dir) && empty(&buftype)
        let b:git_dir = FugitiveExtractGitDir(expand('%:p'))
      endif
      let dir = getbufvar(a:1, 'git_dir')
      return dir =~# s:bad_git_dir ? '' : dir
    elseif type(a:1) == type('')
      return substitute(s:Slash(a:1), '/$', '', '')
    elseif type(a:1) == type({})
      return get(a:1, 'git_dir', '')
    else
      return ''
    endif
  endfunction
  ]])
end

-- Defines custom Yadm command
vim.cmd("command! -nargs=? -complete=customlist,fugitive#Complete Yadm lua require('plugins.fugitive').yadm_command(<f-args>)")
map("n", "<leader>ys", "<cmd>lua require('plugins.fugitive').yadm_command('')<cr>")
map("n", "<leader>yp", "<cmd>lua require('plugins.fugitive').yadm_command('push')<cr>")

return M
