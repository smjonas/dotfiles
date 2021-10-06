local function line_percentage()
  return math.floor((fn.line(".") * 100 / fn.line("$")) + 0.5) .. "%%"
end

local cur_scheme = vim.api.nvim_exec("colorscheme", true)
local statusline_theme = "auto"

if cur_scheme == "tokyonight" then
  statusline_theme = "nightfly"
end

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = statusline_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    -- 1 = show relative path
    lualine_x = {'filetype'},
    lualine_c = { { 'filename', path = 1, symbols = { modified = '[*]' } } },
    lualine_y = {'location', line_percentage},
    lualine_z = {}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { 'filename', symbols = { modified = '[*]' } } },
    lualine_x = { 'location', line_percentage },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}