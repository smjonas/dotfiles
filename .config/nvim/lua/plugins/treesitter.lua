-- local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

-- parser_configs.norg = {
--   install_info = {
--     url = "https://github.com/nvim-neorg/tree-sitter-norg",
--     files = { "src/parser.c", "src/scanner.cc" },

--     branch = "main",
--   },
-- }
local M = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
  },
}

M.config = function()
  require("nvim-treesitter.configs").setup {
    ensure_installed = { "markdown_inline", "luap", "luadoc" },
    ignore_install = { "latex" }, -- VimTex handles this instead
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
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_previous_start = {
          ["[["] = "@function.outer",
        },
        goto_next_start = {
          ["]]"] = "@function.outer",
        },
      },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<c-space>",
        node_incremental = "<c-space>",
        scope_incremental = "<c-s>",
        node_decremental = "<leader><space>",
      },
    },
    include_surrounding_whitespace = true,
  }
end

return M
