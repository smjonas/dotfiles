return {
  "echasnovski/mini.nvim",
  config = function()
    require("mini.ai").setup {
      n_lines = 200,
    }
  end,
}
