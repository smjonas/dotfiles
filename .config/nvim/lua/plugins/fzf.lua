local M = {
  "ibhagwan/fzf-lua",
}

local function project_search()
  local fzf = require("fzf-lua")
  local path = vim.fn.expand("%:p")

  local config_dir = vim.fn.stdpath("config")
  -- If the picker was opened in any of the Nvim config files,
  -- run fzf.files from ~/.config/nvim, otherwise search through the
  -- Git repo the current file is located in
  if path:match("^" .. config_dir) then
    fzf.files { cwd = config_dir }
  else
    local git_root = require("lspconfig.util").root_pattern(".git")(path)
    if git_root then
      return fzf.git_files { cwd = git_root }
    end
  end
end

M.config = function()
  local fzf = require("fzf-lua")
  local telescope_profile = require("fzf-lua.profiles.telescope")

  local opts = { width = 0.75, height = 0.75 }
  fzf.setup {
    "default",
    winopts = vim.tbl_extend("force", telescope_profile.winopts, opts),
    keymap = {
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
    fzf_colors = telescope_profile.fzf_colors,
    fzf_opts = { ["--cycle"] = "" },
  }

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
  end

  map("<leader>fp", project_search, "fzf Find in Project")
  map("<leader>fo", fzf.oldfiles, "fzf Find in Project")
end

return M
