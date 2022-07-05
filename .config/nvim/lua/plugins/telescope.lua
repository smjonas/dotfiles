local actions = require("telescope.actions")

require("telescope").setup {
  defaults = {
    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-c>"] = actions.close,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        ["<CR>"] = actions.select_default + actions.center,
      },
      n = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
    },
    -- sort_mru = true,
    path_display = { "truncate" },
    multi_icon = "",
    -- The following lines were taken from thanhvule0310/dotfiles
    prompt_prefix = "   ○  ",
    selection_caret = "  ",
    entry_prefix = "  ",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.80,
      height = 0.85,
      preview_cutoff = 120,
    },
    border = true,
    borderchars = { "" },
  },
  pickers = {
    live_grep = {
      disable_coordinates = true,
      -- Do not sort by file name etc.
      only_sort_text = true,
      -- Emulate AND operator
      on_input_filter_cb = function(prompt)
        return { prompt = prompt:gsub("%s", ".*") }
      end,
      additional_args = function(opts)
        if opts.search_all == true then
          return {}
        end
        -- Only show results from files of the same filetype as the
        -- buffer where live_grep was opened in (except for Lua files)
        local args_for_ext = {
          lua = { "-tlua", "-tvim" },
          python = { "-tpy" },
          tex = { "-ttex" },
        }
        return args_for_ext[vim.bo.filetype] or {}
      end,
    },
  },
}

-- Cyan Telescope borders
-- vim.cmd [[highlight TelescopeResultsBorder guifg=#56a5e5]]
-- vim.cmd [[highlight TelescopePreviewBorder guifg=#56a5e5]]
-- vim.cmd [[highlight TelescopePromptBorder guifg=#56a5e5]]

local env = vim.env
local builtin = require("telescope.builtin")

local function find_files()
  builtin.find_files {
    cwd = "~",
  }
end

local function project_search()
  local args = {
    -- git_files by default does not search from the current directory of the opened buffer
    cwd = require("lspconfig/util").root_pattern(".git")(vim.fn.expand("%:p")),
    prompt_title = "Git Files",
  }
  if not pcall(builtin.git_files, args) then
    builtin.find_files(args)
  end
end

local inacon_dir = vim.env.HOME .. "/Desktop/Inacon/"

local function find_inacon()
  builtin.find_files {
    prompt_title = "Find Inacon Files",
    search_dirs = { env.INACON_DIR .. "/Kurse", inacon_dir .. "/Automation" },
  }
end

local function find_old_inacon()
  builtin.oldfiles {
    prompt_title = "Find Old Inacon Files",
    search_dirs = { env.INACON_DIR .. "/Kurse", inacon_dir .. "/Automation" },
  }
end

local function find_plugins()
  builtin.find_files {
    prompt_title = "Find Vim Plugins",
    search_dirs = { vim.fn.stdpath("data") },
  }
end

local function find_config()
  builtin.find_files {
    prompt_title = "Find Config Files",
    search_dirs = { vim.fn.stdpath("config") },
  }
end

local function live_grep_git_root()
  local path = vim.fn.expand("%:p")
  local cwd
  -- If the picker was opened in any of the Nvim config files,
  -- use ~/.config/nvim as the cwd instead of looking for a .git directory
  if path:match("^" .. vim.fn.stdpath("config")) then
    cwd = vim.fn.stdpath("config")
  else
    cwd = require("lspconfig/util").root_pattern(".git")(path)
  end
  builtin.live_grep {
    cwd = cwd,
    glob_pattern = "!*plugin/packer_compiled.lua",
  }
end

local opts = {
  silent = true,
}
local map = function(lhs, rhs)
  vim.keymap.set("n", lhs, rhs, opts)
end

-- ReSume
map("<leader>rs", "<cmd>Telescope resume<cr>")

map("<leader>ff", find_files)
map("<leader>fi", find_inacon)
map("<leader>fu", find_old_inacon)
map("<leader>fp", project_search)

-- Find in Vim plugin files
map("<leader>fv", find_plugins)
map("<leader>fc", find_config)
-- map("n", "<leader>vg", '<cmd>lua require("plugins.telescope").grep_plugins()<cr>')

-- Find Old
map("<leader>fo", "<cmd>Telescope oldfiles<cr>")
-- Requires ripgrep to be installed (sudo apt install ripgrep)
map("<leader>fg", live_grep_git_root)

map("<leader>fb", "<cmd>Telescope buffers<cr>")
map("<leader>h", "<cmd>Telescope help_tags<cr>")
-- Keybindings
map("<leader>fk", "<cmd>Telescope keymaps<cr>")

-- RefereNces
map("<leader>fn", "<cmd>Telescope lsp_references<cr>")
