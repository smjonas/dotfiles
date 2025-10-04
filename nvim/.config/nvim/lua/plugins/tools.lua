return {
  { "sindrets/diffview.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = true, enabled = false },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup()
    end,
  },
}
