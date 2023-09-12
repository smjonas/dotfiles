return {
  "AndrewRadev/sideways.vim",
  config = function()
    -- Swap function arguments using Alt + arrow keys
    map("n", "<A-left>", "<cmd>SidewaysLeft<cr>")
    map("n", "<A-right>", "<cmd>SidewaysRight<cr>")
  end,
}
