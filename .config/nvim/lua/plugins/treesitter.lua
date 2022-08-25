-- local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

-- parser_configs.norg = {
--   install_info = {
--     url = "https://github.com/nvim-neorg/tree-sitter-norg",
--     files = { "src/parser.c", "src/scanner.cc" },
--     branch = "main",
--   },
-- }

require("nvim-treesitter.configs").setup {
  ensure_installed = { "comment", "html", "markdown_inline" },
  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ia"] = "@parameter.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
      },
    },
  },
  include_surrounding_whitespace = true,
}
