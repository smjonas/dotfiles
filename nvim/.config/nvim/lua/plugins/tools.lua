return {
  { "sindrets/diffview.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = true },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup()
    end,
  },
  {
    "coffebar/transfer.nvim",
    cmd = {
      "TransferInit",
      "DiffRemote",
      "TransferUpload",
      "TransferDownload",
      "TransferDirDiff",
      "TransferRepeat",
    },
    opts = {},
  },
}
