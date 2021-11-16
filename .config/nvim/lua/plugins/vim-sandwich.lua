
-- Use vim surround-like keybindings
vim.api.nvim_command('runtime macros/sandwich/keymap/surround.vim')
-- '{' will insert space, '}' will not
vim.g['sandwich#recipes'] = vim.list_extend(vim.g['sandwich#recipes'], {
  { buns = { '{ ', ' }' }, nesting = 1, match_syntax = 1, kind = { 'add', 'replace' }, action = { 'add' }, input = { '{' } },
  { buns = { '[ ', ' ]' }, nesting = 1, match_syntax = 1, kind = { 'add', 'replace' }, action = { 'add' }, input = { '[' } },
  { buns = { '( ', ' )' }, nesting = 1, match_syntax = 1, kind = { 'add', 'replace' }, action = { 'add' }, input = { '(' } },
  { buns = { '{\\s*', '\\s*}' },     nesting = 1, regex = 1, match_syntax = 1, kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '{' } },
  { buns = { '\\[\\s*', '\\s*\\]' }, nesting = 1, regex = 1, match_syntax = 1, kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '[' } },
  { buns = { '(\\s*', '\\s*)' },     nesting = 1, regex = 1, match_syntax = 1, kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '(' } },
})
