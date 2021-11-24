local on_attach = function(client, bufnr)
  -- organize imports when leaving buffer
  vim.cmd[[
    augroup organize_imports
      autocmd!
      autocmd BufLeave * silent! PyrightOrganizeImports
    augroup end
  ]]
end

return { on_attach = on_attach }

