" Easier window movements (overwrites argument swapping with alt keys)
" nno <buffer> <A-h> <C-w>h
" nno <buffer> <A-j> <C-w>j
" nno <buffer> <A-k> <C-w>k
" nno <buffer> <A-l> <C-w>l

" Fallback to remapped <Tab> and <S-Tab> (circular window movements) when not in an index file
" autocmd BufAdd index.md let b:is_index_file=1
"
" if !exists("b:is_index_file")
  " augroup vimwiki_no_index
    " autocmd!
    " autocmd BufEnter * echo 'no_index'
    " autocmd BufEnter * nnoremap <buffer> <Tab>   <C-w>w
    " autocmd BufEnter * nnoremap <buffer> <S-Tab> <C-w>W
  " augroup end
" endif
