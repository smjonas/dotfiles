return {
  "chrisgrieser/nvim-spider",
  config = function()
    for _, motion in ipairs { "w", "e", "b" } do
      vim.keymap.set(
        { "n", "o", "x" },
        motion,
        ("<cmd>lua require('spider').motion('%s')<cr>"):format(motion),
        { desc = ("Spider-%s"):format(motion) }
      )
    end
  end,
}
