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
    {
      "nvim-treesitter/nvim-treesitter-context",
      config = { max_lines = 1 },
    },
  },
}

M.init = function()
  print("init")
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      -- Enable treesitter highlighting and disable regex syntax
      pcall(vim.treesitter.start)
    end,
  })

  local ensureInstalled = {
    "markdown_inline",
    "luap",
    "luadoc",
    "lua",
    "python",
    "javascript",
    "typescript",
    "tsx",
    "rust",
    "go",
    "c",
    "cpp",
    "bash",
    "json",
    "yaml",
    "toml",
    "html",
    "css",
    "markdown",
    "vim",
    "vimdoc",
    "query",
  }
  local alreadyInstalled = require("nvim-treesitter.config").get_installed()
  local parsersToInstall = vim
    .iter(ensureInstalled)
    :filter(function(parser)
      return not vim.tbl_contains(alreadyInstalled, parser)
    end)
    :totable()
  require("nvim-treesitter").install(parsersToInstall)
end

M.config = function()
  require("nvim-treesitter").setup {
    ignore_install = { "latex" }, -- VimTex handles this instead
    sync_install = true,
    auto_install = true,
    highlight = {
      enable = true,
    },
    indent = {
      enable = false,
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
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { "BufWrite", "CursorHold" },
    },
  }
end

return M
