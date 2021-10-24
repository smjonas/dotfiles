local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()

parser_configs.norg = {
  install_info = {
    url = 'https://github.com/nvim-neorg/tree-sitter-norg',
    files = { 'src/parser.c', 'src/scanner.cc' },
    branch = 'main'
  }
}

require('nvim-treesitter.configs').setup {
  ensure_installed = { 'css', 'haskell', 'html', 'java', 'latex', 'lua', 'norg', 'php', 'python', 'vim', 'yaml' },
  highlight = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['ia'] = {
          html = "@custom_attribute.inner"
        }
      }
    }
  }
}
