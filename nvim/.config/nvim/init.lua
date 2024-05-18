-- Testing editree
vim.api.nvim_create_user_command("ET", function()
  vim.cmd("Fern %:h -drawer -toggle -reveal=%")
end, { nargs = "*", complete = "file" })

-- Fixes wrong terminal colors when using tmux
vim.cmd([[
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
]])

vim.cmd([[
runtime mappings.vim
" Faster keyboard movement
silent !xset r rate 215 35

augroup dotfiles

 autocmd!
 " Enable highlight on yank
 autocmd TextYankPost * silent! lua vim.highlight.on_yank { timeout = 130 }
 " Equalize splits after resizing
 autocmd VimResized * wincmd =
 " Open help files in a vertical split
 autocmd FileType help wincmd L
 " Do not wrap text, only comments. This somehow does not work when set
 " as a global option (see https://vi.stackexchange.com/a/9366/37072)
 autocmd FileType * set formatoptions-=t
 " Automatically enter insert mode when in terminal mode
 autocmd BufEnter term://* startinsert

augroup end
]])

require("global_settings").apply_defaults()

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Open file at the last position it was edited earlier",
  pattern = "*",
  command = 'silent! normal! g`"zv',
})

-- Load config files
require("utils")
require("options")
require("lazyinit")

local function reload_dev_modules()
  for _, plugin in ipairs {
    "plugin_list",
    "plugin_settings",
    "live-command",
    "inc_rename",
    "snippet_converter",
  } do
    package.loaded[plugin] = nil
  end
end

local function reload_config()
  reload_dev_modules()
  vim.cmd([[
:luafile ~/.config/nvim/lua/lazyinit.lua
:luafile ~/.config/nvim/lua/options.lua
:runtime mappings.vim
]])
end

vim.api.nvim_create_user_command("ReloadConfig", reload_config, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/nvim/*",
  callback = reload_config,
  desc = "Reload config on save",
})

local function smart_dd()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end

vim.keymap.set("n", "dd", smart_dd, { expr = true })
