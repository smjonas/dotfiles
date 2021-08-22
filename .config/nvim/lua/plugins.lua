local g = vim.g
local fn = vim.fn
local env = vim.env
local lsp = vim.lsp

local lsp_conf = require("lspconfig")
local coq = require("coq")

local servers = {"pyright", "html", "vimls", "hls"}
for _, server in ipairs(servers) do
    lsp_conf[server].setup(coq.lsp_ensure_capabilities())
end

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
    lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

g.coq_settings = {
    auto_start = true,
    keymap = { recommended = false },
    display = { pum = { source_context = { "[", "]" } } }
}

require("lint").linters_by_ft = {
    python = {'flake8'}
}

require("lspsaga").init_lsp_saga {
  error_sign = '>>',
  warn_sign = '>>'
}

require("py_lsp").setup {
    host_python = env.INACON_VENV_PYTHON
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

local cur_scheme = vim.api.nvim_exec("colorscheme", true)
local statusline_theme = cur_scheme
if cur_scheme == "tokyonight" then
    statusline_theme = "nightfly"
end

local function line_percentage()
    return math.floor((fn.line(".") * 100 / fn.line("$")) + 0.5) .. "%%"
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
    lualine_x = {'filetype'},
    lualine_y = {'location', line_percentage},
    lualine_z = {}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {'filename', symbols = {modified = '[*]'} } },
    lualine_x = {'location', line_percentage},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

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
        ["ic"] = "@class.inner"
      }
    }
  }
}

require("nvim-autopairs").setup {
    disable_filetype = { "TelescopePrompt" , "vim" }
}

--[[ require("auto-session").setup {
} ]]

-- project.nvim
require("project_nvim").setup {
    silent_chdir = false
}

local telescope = require("telescope")
local builtin = require("telescope.builtin")
telescope.setup()
telescope.load_extension("fzf")
telescope.load_extension("projects")

local M = {}
function M.find_files()
    builtin.find_files {
        prompt_title = "Find files",
        cwd = "~",
        hidden = true,
        sort_mru = true
    }
end

function M.find_buffers()
    builtin.buffers {
        sort_mru = true
    }
end

function M.find_inacon()
    builtin.find_files {
        prompt_title = "Find files in Inacon",
        search_dirs = { env.INACON_DIR .. "/Kurse", env.INACON_DIR .. "/Automation" },
        sort_mru = true
    }
end

function M.find_old_inacon()
    builtin.oldfiles {
        prompt_title = "Find old files in Inacon",
        search_dirs = { env.INACON_DIR .. "/Kurse", env.INACON_DIR .. "/Automation" },
        sort_mru = true
    }
end
return M

