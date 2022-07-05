local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()

parser_configs.norg = {
  install_info = {
    url = "https://github.com/nvim-neorg/tree-sitter-norg",
    files = { "src/parser.c", "src/scanner.cc" },
    branch = "main",
  },
}

local ts_parsers = require("nvim-treesitter.parsers")

-- Auto-install missing treesitter parser when entering buffer
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "*" },
  callback = function()
    local lang = ts_parsers.get_buf_lang()
  if ts_parsers.get_parser_configs()[lang] and not ts_parsers.has_parser(lang) then
    vim.schedule_wrap(function()
    vim.cmd("TSInstall "..lang)
    end)()
  end
  end,
})

require("nvim-treesitter.configs").setup {
  ensure_installed = { "markdown_inline" },
  sync_install = true,
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
        ["aa"] = "@parameter.outer",
      },
    },
  },
}
