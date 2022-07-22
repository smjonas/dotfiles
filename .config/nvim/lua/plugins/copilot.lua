-- local map = require("utils").map

-- map("n", "<C-f>", "copilot#Accept('\\<CR>')", { noremap = false, script = true, expr = true })
vim.g["g_copilot_no_tab_map"] = true
vim.g["g_copilot_assume_mapped"] = true

local excluded_filetypes = { "nofile", "prompt" }
local copilot_filetypes = {}
for _, ft in pairs(excluded_filetypes) do
  copilot_filetypes[ft] = false
end

vim.g["copilot_filetypes"] = copilot_filetypes
