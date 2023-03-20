local M = {
  "ibhagwan/fzf-lua",
}

local function get_root_dir()
  local path = vim.fn.expand("%:p")
  -- If the picker was opened in any of the Nvim config files,
  -- return ~/.config/nvim as the cwd, otherwise use the Git repo the current file
  -- is located in
  if path:match("^" .. vim.fn.stdpath("config")) then
    return vim.fn.stdpath("config"), false
  else
    return require("lspconfig/util").root_pattern(".git")(path), true
  end
end

local function project_search()
  local fzf = require("fzf-lua")
  local path, is_git_root = get_root_dir()

  if is_git_root then
    return fzf.git_files { cwd = path }
  else
    fzf.files { cwd = path }
  end
end

local function grep_git_root(fzf_grep_fn)
  return function()
    fzf_grep_fn { cwd = get_root_dir() }
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

  map("<leader>ff", fzf.files, "fzf Find Files")
  map("<leader>fp", project_search, "fzf Find in Project")
  map("<leader>fo", fzf.oldfiles, "fzf Find Old Files")

  map("<leader>fg", grep_git_root(fzf.live_grep), "fzf Find with ripGrep")
end

return M
