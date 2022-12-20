return {
  "anuvyklack/windows.nvim",
  dependencies = {
    "anuvyklack/middleclass",
    "anuvyklack/animation.nvim"
  },
  config = function()
    require("windows").setup {
      animation = {
        enable = false,
      },
    }
  end,
}
