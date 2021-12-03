vim.g["fern#drawer_width"] = 30
local map = require("utils").map
map("n", "<C-n>", "<cmd>Fern %:h -drawer -toggle -reveal=%<cr>")
map("n", "<M-n>", "<cmd>Fern %:h<cr>")

vim.cmd[[
  function! s:init_fern() abort
    nmap <buffer> d <Plug>(fern-action-trash)
    nmap <buffer> . <Plug>(fern-action-hidden-toggle)
    nmap <buffer> nf <Plug>(fern-action-new-file)
    nmap <buffer> nd <Plug>(fern-action-new-dir)
  endfunction

  augroup fern_custom
    autocmd!
    autocmd FileType fern call s:init_fern()
  augroup end
]]
