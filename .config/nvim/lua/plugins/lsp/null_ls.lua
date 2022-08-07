local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

require("null-ls").setup {
  sources = {
    formatting.stylua,
    formatting.prettier.with {
      extra_args = { "--bracket-same-line", "true", "--print-width", "110" },
      filetypes = { "css", "html", "javascript", "json", "xhtml" },
    },
    formatting.black.with { extra_args = { "--line-length", "110" } },
    -- formatting.isort.with({ extra_args = { "--profile black" } }),
    formatting.isort,
    formatting.gofmt,
  },
}
