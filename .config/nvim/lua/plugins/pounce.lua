return {
  "rlane/pounce.nvim",
  config = function()
    vim.keymap.set("n", "<C-s>", vim.cmd.Pounce)
  end,
}
