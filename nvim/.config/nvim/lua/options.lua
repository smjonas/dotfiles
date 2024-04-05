local o = vim.opt

-- Auto-save when switching to different buffer using ctrl-6
o.autowriteall = true
-- Use system clipboard
-- o.clipboard = o.clipboard ^ "unnamed,unnamedplus"
o.cmdheight = 2
-- Autocomplete settings
-- o.completeopt = "menuone,noselect,preview"
o.completeopt = "menu,menuone"
o.cursorline = true
-- o.diffopt = o.diffopt + "linematch:60"
o.expandtab = true
-- Don't make all windows the same size when resizing (also required for windows.nvim)
o.equalalways = false
-- Global status bar
-- o.laststatus = 3
o.fillchars:append {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┨",
  vertright = "┣",
  verthoriz = "╋",
}
-- Do not open folds when moving with { or }
o.foldopen = o.foldopen - "block"
o.hlsearch = false
o.ignorecase = true
-- Show replacement results while typing command
o.inccommand = "nosplit"
-- Drag window with mouse
o.mouse = "a"
o.mousescroll = "ver:4"
-- Winbar (code context + right-aligned filename)
local ok, _ = pcall(require, "nvim-navic")
if ok then
  o.winbar = " %f %= %{%v:lua.require'nvim-navic'.get_location()%} "
end
-- Crispy window separators
-- vim.cmd("highlight WinSeparator guibg=None")
o.number = true
o.pumheight = 10
o.relativenumber = true
o.scrolloff = 9
o.sessionoptions = o.sessionoptions + "resize,winpos,terminal"
o.sessionoptions = o.sessionoptions - "buffers"
o.shiftround = true
o.shiftwidth = 2
-- Do not display ins-completion-menu messages
o.shortmess = o.shortmess + "c"
-- Current mode in insert mode is not necessary when using status line plugin
o.showmode = false
o.sidescrolloff = 6
o.signcolumn = "yes:1"
o.smartcase = true
o.splitbelow = false
o.splitright = true
-- Try to stay in the current column, e.g. when deleting the current line
o.startofline = false
o.swapfile = false
o.synmaxcol = 250
o.tabstop = 4
o.termguicolors = true
o.textwidth = 90
o.timeoutlen = 250
o.undofile = true
-- Enables selecting a block of text across line boundaries
o.virtualedit = o.virtualedit + "block"
o.wildignorecase = true
o.winminwidth = 10
o.wrap = false
