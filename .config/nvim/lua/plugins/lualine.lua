local cur_scheme = vim.api.nvim_exec("colorscheme", true)
local scheme_map = {
  tokyonight = "nightfly",
}
local statusline_theme = scheme_map[cur_scheme] or cur_scheme

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = statusline_theme,
    -- section_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    -- component_separators = { left = "", right = "" },
    component_separators = { left = "|", right = "|" },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    -- 1 = show relative path
    lualine_c = {
      {
        "filename",
        fmt = function(str)
          return vim.bo.filetype == "fern" and "" or str
        end,
        path = 1,
        symbols = { modified = "[*]" },
      },
    },
    lualine_x = { --[[ "searchcount" ]] },
    lualine_y = { "filetype" },
    lualine_z = {
      {
        "location",
        -- color = { fg = colors.fg, bg = colors.active },
      },
      { "progress" },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { "filename", symbols = { modified = "[*]" } } },
    lualine_x = { "location", "progress" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
