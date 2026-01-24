return {
  "zbirenbaum/copilot.lua",
  config = function()
    require("copilot").setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
    }
  end,
  dependencies = {
    "copilotlsp-nvim/copilot-lsp",
  },
  event = "InsertEnter",
}
