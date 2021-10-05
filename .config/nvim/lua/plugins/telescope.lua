require('telescope').setup {
  defaults = {
    -- sort_mru = true,
    path_display = { "truncate" }
  }
}
-- Cyan Telescope borders
vim.cmd [[highlight TelescopeResultsBorder guifg=#56a5e5]]
vim.cmd [[highlight TelescopePreviewBorder guifg=#56a5e5]]
vim.cmd [[highlight TelescopePromptBorder guifg=#56a5e5]]

local M = {}
function M.find_files()
  builtin.find_files {
    cwd = "~",
    hidden = true
  }
end

function M.project_search()
  builtin.find_files {
    previewer = false,
    prompt_title = "Project Search",
    layout_strategy = "vertical",
    cwd = require("lspconfig/util").root_pattern ".git"(vim.fn.expand "%:p"),
  }
end

function M.find_inacon()
  builtin.find_files {
    prompt_title = "Find Inacon Files",
    search_dirs = { env.INACON_DIR .. "/Kurse", env.INACON_DIR .. "/Automation" }
  }
end

function M.find_old_inacon()
  builtin.oldfiles {
    prompt_title = "Find Old Inacon Files",
    search_dirs = { env.INACON_DIR .. "/Kurse", env.INACON_DIR .. "/Automation" }
  }
end
return M
