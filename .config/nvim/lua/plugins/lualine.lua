local function line_percentage()
  return math.floor((vim.fn.line(".") * 100 / vim.fn.line("$")) + 0.5) .. "%%"
end

local statusline_theme = vim.g.colorscheme

local cur_scheme = vim.api.nvim_exec("colorscheme", true)
local scheme_map = { tokyonight = "nightfly", edge = "edge", onenord = "onenord" }
statusline_theme = vim.tbl_contains(vim.tbl_keys(scheme_map), cur_scheme) and scheme_map[cur_scheme]
  or statusline_theme

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = statusline_theme,
    -- component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    -- 1 = show relative path
    lualine_x = { "filetype" },
    lualine_c = { { "filename", path = 1, symbols = { modified = "[*]" } } },
    lualine_y = { "location", line_percentage },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { "filename", symbols = { modified = "[*]" } } },
    lualine_x = { "location", line_percentage },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
