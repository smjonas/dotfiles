local M = {
  "jose-elias-alvarez/null-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
}

M.config = function()
  local null_ls = require("null-ls")
  local formatting = null_ls.builtins.formatting

  require("null-ls").setup {
    sources = {
      formatting.stylua,
      formatting.prettier.with {
        extra_args = { "--bracket-same-line", "true", "--print-width", "110" },
        filetypes = { "css", "html", "javascript", "json", "xhtml" },
      },
      formatting.xq.with {
        filetypes = { "xml" },
      },
      formatting.black.with { extra_args = { "--line-length", "130" } },
      -- formatting.isort.with({ extra_args = { "--profile black" } }),
      formatting.isort,
      formatting.gofmt,
      formatting.format_r,
    },
  }
end

return M
