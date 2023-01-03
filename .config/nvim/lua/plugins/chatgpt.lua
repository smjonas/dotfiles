return {
  "jackMort/ChatGPT.nvim",
  enable = false,
  config = function()
    require("chatgpt").setup()
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
}
