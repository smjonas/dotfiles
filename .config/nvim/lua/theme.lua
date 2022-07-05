local M = {}

-- OneNord stuff

-- M.colors = {
--   bg = "#2e3440",
--   fg = "#ECEFF4",
--   red = "#bf616a",
--   orange = "#d08770",
--   yellow = "#ebcb8b",
--   blue = "#5e81ac",
--   green = "#a3be8c",
--   cyan = "#88c0d0",
--   magenta = "#b48ead",
--   pink = "#FFA19F",
--   grey1 = "#f8fafc",
--   grey2 = "#f0f1f4",
--   grey3 = "#eaecf0",
--   grey4 = "#d9dce3",
--   grey5 = "#c4c9d4",
--   grey6 = "#b5bcc9",
--   grey7 = "#929cb0",
--   grey8 = "#8e99ae",
--   grey9 = "#74819a",
--   grey10 = "#616d85",
--   grey11 = "#464f62",
--   grey12 = "#3a4150",
--   grey13 = "#333a47",
--   grey14 = "#242932",
--   grey15 = "#1e222a",
--   grey16 = "#1c1f26",
--   grey17 = "#0f1115",
--   grey18 = "#0d0e11",
--   grey19 = "#020203",
-- }

-- M.init = function()
--   local ok, onenord = pcall(require, "onenord")
--   if ok then
--     onenord.setup {
--       borders = true,
--       fade_nc = false,
--       styles = {
--         comments = "italic",
--         strings = "NONE",
--         keywords = "NONE",
--         functions = "italic",
--         variables = "bold",
--         diagnostics = "underline",
--       },
--       disable = {
--         background = false,
--         cursorline = false,
--         eob_lines = true,
--       },
--       custom_highlights = {
--         VertSplit = { fg = M.colors.grey14 },
--         BufferLineIndicatorSelected = { fg = M.colors.cyan, bg = M.colors.bg },
--         BufferLineFill = { fg = M.colors.fg, bg = M.colors.grey14 },
--         NvimTreeNormal = { fg = M.colors.grey5, bg = M.colors.grey14 },
--         WhichKeyFloat = { bg = M.colors.grey14 },
--         GitSignsAdd = { fg = M.colors.green },
--         GitSignsChange = { fg = M.colors.orange },
--         GitSignsDelete = { fg = M.colors.red },
--         NvimTreeFolderIcon = { fg = M.colors.grey9 },
--         NvimTreeIndentMarker = { fg = M.colors.grey12 },

--         NormalFloat = { bg = M.colors.grey14 },
--         FloatBorder = { bg = M.colors.grey14, fg = M.colors.grey14 },

--         TelescopePromptPrefix = { bg = M.colors.grey14 },
--         TelescopePromptNormal = { bg = M.colors.grey14 },
--         TelescopeResultsNormal = { bg = M.colors.grey15 },
--         TelescopePreviewNormal = { bg = M.colors.grey16 },

--         TelescopePromptBorder = { bg = M.colors.grey14, fg = M.colors.grey14 },
--         TelescopeResultsBorder = { bg = M.colors.grey15, fg = M.colors.grey15 },
--         TelescopePreviewBorder = { bg = M.colors.grey16, fg = M.colors.grey16 },

--         TelescopePromptTitle = { fg = M.colors.grey14 },
--         TelescopeResultsTitle = { fg = M.colors.grey15 },
--         TelescopePreviewTitle = { fg = M.colors.grey16 },

--         PmenuSel = { bg = M.colors.grey12 },
--         Pmenu = { bg = M.colors.grey14 },
--         PMenuThumb = { bg = M.colors.grey16 },

--         LspFloatWinNormal = { fg = M.colors.fg, bg = M.colors.grey14 },
--         LspFloatWinBorder = { fg = M.colors.grey14 },
--       },
--     }
--   end
-- end

M.init = function() end

return M
