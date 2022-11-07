vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "qf",
    "help",
    "man",
    -- "lir",
    "tsplayground",
  },
  callback = function()
    vim.cmd([[
      nnoremap <silent> <buffer> q :close<cr>
      nnoremap <silent> <buffer> <esc> :close<cr>
    ]])
  end,
})
