return {
  "jackMort/ChatGPT.nvim",
  dev = true,
  config = function()
    require("chatgpt").setup()
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
}
