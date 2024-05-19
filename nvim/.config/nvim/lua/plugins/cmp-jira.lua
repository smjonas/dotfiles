return {
  "smjonas/cmp-jira",
  ft = "gitcommit",
  config = function()
    require("cmp_jira").setup { file_types = { "gitcommit" } }
  end,
}
