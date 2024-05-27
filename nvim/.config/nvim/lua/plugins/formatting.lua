local add_prettier = function(formatters_by_ft)
  require("conform").formatters.prettier = {
    prepend_args = { "--bracket-same-line", "true", "--print-width", "110" },
  }
  local prettier_fts = { "css", "html", "javascript", "json", "xhtml" }
  for _, ft in ipairs(prettier_fts) do
    formatters_by_ft[ft] = { "prettier" }
  end
end

return {
  "stevearc/conform.nvim",
  config = function()
    local formatters_by_ft = {
      go = { "gofmt" },
      php = { "php_cs_fixer" },
      lua = { "stylua" },
      python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
      rust = { "rustfmt" },
      xml = { "xmlformat" },
    }
    add_prettier(formatters_by_ft)
    require("conform").setup {
      formatters_by_ft = formatters_by_ft,
    }
  end,
}
