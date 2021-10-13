local o = vim.opt

-- Auto-save when switching to different buffer using ctrl-6
o.autowriteall = true
o.background = "dark"
-- Use system clipboard
-- o.clipboard = o.clipboard ^ "unnamed,unnamedplus"
o.cmdheight = 2
-- Autocomplete settings
o.completeopt = "menuone,noselect,preview"
o.cursorline = true
o.expandtab = true
-- Do not open folds when moving with { or }
o.foldopen = o.foldopen - "block"
o.hidden = true
o.ignorecase = true
-- Show replacement results while typing command
o.inccommand = "nosplit"
o.incsearch = true
-- Drag window with mouse
o.mouse = "a"
o.hlsearch = false
o.joinspaces = false
o.number = true
o.relativenumber = true
o.scrolloff = 9
o.sessionoptions = o.sessionoptions + "resize,winpos,terminal"
o.sessionoptions = o.sessionoptions - "buffers"
o.shiftround = true
o.shiftwidth = 4
-- Do not display ins-completion-menu messages
o.shortmess = o.shortmess + "c"
-- Current mode in insert mode is not necessary when using status line plugin
o.showmode = false
o.sidescrolloff = 6
-- Display diagnostics signs instead of line number (if there is a symbol to show)
o.signcolumn = "number"
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
o.undodir = vim.env.HOME .. vim.fn.stdpath("data") .. "/undo"
o.undofile = true
-- Enables selecting a block of text across line boundaries
o.virtualedit = o.virtualedit + "block"
o.wildignorecase = true
o.wrap = false
