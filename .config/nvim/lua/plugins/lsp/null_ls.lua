local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

require("null-ls").setup {
  sources = {
    formatting.stylua,
    formatting.prettier.with {
      extra_args = { "--tab-width 4", "--bracket-same-line" },
      filetypes = { "html", "javascript", "json", "xhtml" },
    },
    formatting.black.with { extra_args = { "--line-length 100" } },
    -- formatting.isort.with({ extra_args = { "--profile black" } }),
    formatting.isort,
  },
}
