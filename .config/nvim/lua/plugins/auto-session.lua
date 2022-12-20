return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup {
      auto_restore_enabled = false,
    }
  end,
}
