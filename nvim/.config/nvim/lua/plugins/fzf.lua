local M = {
  "ibhagwan/fzf-lua",
  keys = { "<leader>fp", "<leader>fo", "<leader>fg" },
}

local function get_root_dir()
  local path = vim.fn.expand("%:p")
  -- If the picker was opened in any of the Nvim config files,
  -- return ~/.config/nvim as the cwd, otherwise use the Git repo the current file
  -- is located in
  if vim.startswith(path, vim.fn.stdpath("config")) then
    return vim.fn.stdpath("config"), false
  else
    return require("lspconfig/util").root_pattern(".git")(path), true
  end
end

local function project_search()
  local fzf = require("fzf-lua")
  local path, is_git_root = get_root_dir()

  local opts = {
    cwd = path,
    cmd = "git ls-files --cached --exclude-standard",
  }
  if is_git_root then
    return fzf.git_files(opts)
  else
    fzf.files(opts)
  end
end

local function grep_git_root(fzf_grep_fn)
  return function()
    fzf_grep_fn { cwd = get_root_dir(), fzf_opts = { ["--keep-right"] = "" }, resume = true }
  end
end

M.config = function()
  local fzf = require("fzf-lua")
  local telescope_profile = require("fzf-lua.profiles.telescope")

  local opts = { width = 0.75, height = 0.75 }
  fzf.setup {
    "default",
    winopts = vim.tbl_extend("force", telescope_profile.winopts, opts),
    defaults = { formatter = "path.filename_first" },
    keymap = {
      builtin = {
        ["<C-u>"] = "preview-page-up",
        ["<C-d>"] = "preview-page-down",
      },
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
    fzf_colors = telescope_profile.fzf_colors,
    fzf_opts = { ["--cycle"] = "", ["--keep-right"] = "" },
  }

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
  end

  -- map("<leader>ff", find_files, "[f]ind [f]iles")
  map("<leader>fp", project_search, "[f]ind in [p]roject files")
  map("<leader>fo", fzf.oldfiles, "[f]ind [o]ld files")

  map("<leader>fg", grep_git_root(fzf.live_grep), "[f]ind with rip[g]rep")
end

return M
