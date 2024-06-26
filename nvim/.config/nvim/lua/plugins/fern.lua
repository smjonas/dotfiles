local M = {
  "lambdalisue/fern.vim",
  dependencies = { "lambdalisue/fern-renderer-nerdfont.vim", "lambdalisue/nerdfont.vim" },
}

M.config = function()
  vim.g["fern#drawer_width"] = 40
  -- vim.g["fern#renderer"] = "nerdfont"
  local map = vim.keymap.set
  -- map("n", "<C-n>", "<cmd>Fern %:h -drawer -toggle -reveal=%<cr>")
  map("n", "<M-n>", "<cmd>Fern %:h<cr>")

  vim.cmd([[
  function! s:init_fern() abort
    nmap <buffer> d <Plug>(fern-action-trash)
    nmap <buffer> . <Plug>(fern-action-hidden-toggle)
    nmap <buffer> nf <Plug>(fern-action-new-file)
    nmap <buffer> nd <Plug>(fern-action-new-dir)
    nmap <buffer> <Plug>(fern-action-open-or-expand) <Plug>(fern-action-open:select)
  endfunction

  augroup fern_custom
    autocmd!
    autocmd FileType fern call s:init_fern()
  augroup end
]])
end

return M
