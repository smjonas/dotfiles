return {
  "folke/noice.nvim",
  enabled = false,
  -- event = "VimEnter",
  config = function()
    require("noice").setup {
      presets = { inc_rename = true },
    }
  end,
  dependencies = { "MunifTanjim/nui.nvim" },
}
