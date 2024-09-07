return {
  "smjonas/cmp-jira",
  ft = "gitcommit",
  config = function()
    require("cmp_jira").setup {
      file_types = { "gitcommit" },
      enabled = function()
        local file_name = vim.fn.expand("%:p")
        local enable_pattern = ".*/NeoCargo/.*/COMMIT_EDITMSG"
        return file_name:find(enable_pattern) ~= nil
      end,
      jira = {
        jql = '(assignee=%s+OR+reporter=%s)+AND+resolution=unresolved+AND+status+!=+"TO+DO"+ORDER+BY+updated+DESC',
      },
    }
  end,
}
