return {
  "rlane/pounce.nvim",
  enabled = false,
  config = function()
    vim.keymap.set("n", "<C-s>", vim.cmd.Pounce)
  end,
}
