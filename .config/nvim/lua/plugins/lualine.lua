local M = {
  "nvim-lualine/lualine.nvim",
}

M.config = function()
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
      lualine_x = { --[[ "searchcount" ]]
      },
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

  -- Better floating window colors
  -- local normal_float_bg = vim.fn.synIDattr(vim.fn.hlID("NormalFloat"), "bg")
  -- print(normal_float_bg)
  -- local normal_fg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "fg")
  -- vim.cmd("highlight FloatBorder guifg=" .. normal_fg .. " guibg=" .. normal_float_bg)
end

return M
