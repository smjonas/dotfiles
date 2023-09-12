vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

-- Enables gf on Lua module name
vim.opt_local.suffixesadd:prepend(".lua")
vim.opt_local.path:prepend(".")
vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"
