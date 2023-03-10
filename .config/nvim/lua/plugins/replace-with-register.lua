return {
  "inkarkat/vim-ReplaceWithRegister",
  config = function()
    vim.cmd([[
        nmap r <Plug>ReplaceWithRegisterOperator
        nmap rr <Plug>ReplaceWithRegisterLine
        " replace from clipboard
        nmap R "+r
        nnoremap gr r
        nnoremap <leader>r R
    ]])
  end,
}
