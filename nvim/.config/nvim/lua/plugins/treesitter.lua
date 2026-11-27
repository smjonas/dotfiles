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
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    {
      "nvim-treesitter/nvim-treesitter-context",
      config = { max_lines = 1 },
    },
  },
}

M.init = function()
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      pcall(vim.treesitter.start)
    end,
  })
end

M.config = function()
  -- nvim-treesitter `main` branch: highlighting is started via the FileType
  -- autocmd in M.init; the old `configs` module options no longer exist.
  require("nvim-treesitter").setup {}

  require("nvim-treesitter-textobjects").setup {
    select = { include_surrounding_whitespace = true },
    move = { set_jumps = true },
  }

  local move = require "nvim-treesitter-textobjects.move"
  vim.keymap.set({ "n", "x", "o" }, "]]", function()
    move.goto_next_start("@function.outer", "textobjects")
  end, { desc = "Next function start" })
  vim.keymap.set({ "n", "x", "o" }, "[[", function()
    move.goto_previous_start("@function.outer", "textobjects")
  end, { desc = "Previous function start" })
end

return M
