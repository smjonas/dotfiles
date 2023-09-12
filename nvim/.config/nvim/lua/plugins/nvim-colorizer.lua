return {
  "NvChad/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup {
      filetypes = { "css", "html", "lua", "php" },
    }
  end,
}
