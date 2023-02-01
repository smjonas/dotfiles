-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
  dev = {
    path = "~/Desktop/NeovimPlugins",
    patterns = { "smjonas" },
  },
  install = { colorscheme = { "tokyonight" } },
  change_detection = { enabled = false },
  ui = { wrap = true },
})

vim.keymap.set("n", "<leader>l", "<cmd>:Lazy<cr>")
vim.keymap.set("n", "<leader>u", "<cmd>:Lazy update<cr>")
vim.keymap.set("n", "<leader>i", "<cmd>:Lazy install<cr>")
