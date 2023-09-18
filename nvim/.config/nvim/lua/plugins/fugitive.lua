local M = {
  "tpope/vim-fugitive",
}

-- Hack to temporarily replace fugitive's current Git directory with the root of the
-- dotfiles folder.
function M.stow_command(cmd)
  vim.cmd([[
  function! FugitiveGitDir(...) abort
    return $HOME .. "/dotfiles/.git"
  endfunction
  ]])

  vim.cmd("Git " .. (cmd or ""))

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

M.config = function()
  local map = vim.keymap.set
  map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
  map("n", "<leader>gp", "<cmd>Git push<cr>")
  map("n", "<leader>gl", "<cmd>Git pull<cr>")

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "fugitive",
    callback = function()
      local opts = { buffer = true }
      map("n", "<leader>gf", "<cmd>Git push -f<cr>", opts)
      map("n", "<leader>gh", "<cmd>Git stash<cr>", opts)

      opts.remap = true
      -- Change default behavior of o to open file in vertical split
      map("n", "o", "gO", opts)
    end,
  })

  -- Defines custom Stow command
  vim.cmd(
    "command! -nargs=? -complete=customlist,fugitive#Complete Stow lua require('plugins.fugitive').stow_command(<f-args>)"
  )

  map("n", "<leader>ys", function()
    M.stow_command("")
  end, { desc = "Stow status" })

  map("n", "<leader>yp", function()
    M.stow_command("push")
  end, { desc = "Stow push" })

  map("n", "<leader>yl", function()
    M.stow_command("pull")
  end, { desc = "Stow pull" })
end
return M
