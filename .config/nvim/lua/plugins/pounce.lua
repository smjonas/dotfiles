return {
  "rlane/pounce.nvim",
  config = function()
    vim.keymap.set("n", "s", vim.cmd.Pounce)
  end,
}
