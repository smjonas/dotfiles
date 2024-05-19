return {
  "rmagatti/auto-session",
  keys = { "<F5>", "<F6>" },
  cmd = "Autosession",
  config = function()
    require("auto-session").setup {
      auto_restore_enabled = false,
    }

    vim.keymap.set("n", "<F5>", function()
      local ok = pcall(vim.cmd.SessionSave)
      if ok then
        print("Session saved")
      end
    end)

    vim.keymap.set("n", "<F6>", function()
      local ok = pcall(vim.cmd.SessionSave)
      if ok then
        print("Session restored")
      end
    end)
  end,
}
