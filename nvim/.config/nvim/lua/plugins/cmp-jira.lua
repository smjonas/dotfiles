return {
  "smjonas/cmp-jira",
  ft = "gitcommit",
  config = function()
    require("cmp_jira").setup {
      file_types = { "gitcommit" },
      jira = {
        jql = '(assignee=%s+OR+reporter=%s)+AND+resolution=unresolved+AND+status+!=+"TO+DO"',
      },
    }
  end,
}
