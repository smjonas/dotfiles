local fn = vim.fn
local g = vim.g

-- Adds new text objects
require("nvim-treesitter.configs").setup {
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
      },
    },
  },
}
local lsp = require("lspconfig")
local coq = require("coq")
local servers = {"pyright", "html", "vimls"}
for _, server in ipairs(servers) do
    lsp[server].setup(coq.lsp_ensure_capabilities())
end

-- Coq settings
g.coq_settings = {
    ["auto_start"] = true,
    ["display.pum.source_context"] = { "[", "]" }
}

require("lspsaga").init_lsp_saga {
  error_sign = '>>',
  warn_sign = '!'
}

require("py_lsp").setup {
    host_python = vim.env.INACON_VENV_PYTHON
}

local devicons = require("nvim-web-devicons")
local all_icons = devicons.get_icons()
local black_white_icons = all_icons

for k, _ in pairs(all_icons) do
    -- Set devicons to same color as normal text color (e.g. in Telescope prompt)
    black_white_icons[k]["color"] = cur_text_color
end

devicons.setup {
    override = black_white_icons
}

-- project.nvim
require("project_nvim").setup {
    silent_chdir = false,
    show_hidden = true
}

local telescope = require("telescope")
telescope.setup()
telescope.load_extension("fzf")
telescope.load_extension("projects")

local cur_scheme = vim.api.nvim_exec("colorscheme", true)
local statusline_theme = cur_scheme
if cur_scheme == "tokyonight" then
    statusline_theme = "nightfly"
end

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = statusline_theme,
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = { {'filename', full_path = true, symbols = {modified = '[*]'} } },
    lualine_x = {'fileformat', 'filetype'},
    lualine_y = {'location'},
    lualine_z = {}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {'filename', symbols = {modified = '[*]'} } },
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

require("nvim-autopairs").setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})

