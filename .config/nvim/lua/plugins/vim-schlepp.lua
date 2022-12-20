return {
  "zirrostig/vim-schlepp",
  config = function()
    map("v", "<up>", "<Plug>SchleppUp", { noremap = false })
    map("v", "<down>", "<Plug>SchleppDown", { noremap = false })
    map("v", "<left>", "<Plug>SchleppLeft", { noremap = false })
    map("v", "<right>", "<Plug>SchleppRight", { noremap = false })
  end,
}
