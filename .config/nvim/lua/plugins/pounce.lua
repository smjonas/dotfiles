return {
  "rlane/pounce.nvim",
  enabled = false,
  config = function()
    vim.keymap.set("n", "s", vim.cmd.Pounce)
  end,
}
