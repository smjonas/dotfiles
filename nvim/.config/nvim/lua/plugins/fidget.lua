return {
  "j-hui/fidget.nvim",
  branch = "legacy",
  config = function()
    require("fidget").setup {
      text = {
        spinner = "dots",
      },
      timer = {
        fidget_decay = 0,
        task_decay = 0,
      },
    }
  end,
}
