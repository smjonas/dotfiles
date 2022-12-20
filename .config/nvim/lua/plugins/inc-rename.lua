return {
  "smjonas/inc-rename.nvim",
  branch = "preview",
  -- "smjonas/inc-rename.nvim",
  config = function()
    require("inc_rename").setup {
      async = true,
      hl_group = "IncSearch",
    }
  end,
}
