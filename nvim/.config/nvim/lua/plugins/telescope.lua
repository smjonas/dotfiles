local M = {
  "nvim-telescope/telescope.nvim",
  -- "~/Desktop/NeovimPlugins/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
}

function M.find_config()
  require("telescope.builtin").find_files {
    prompt_title = "Find Config Files",
    search_dirs = { vim.fn.stdpath("config") },
    -- Follow symlinks
    follow = true,
  }
end

M.config = function()
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
          ["<C-f>"] = require("telescope.actions.layout").toggle_preview,
          ["<Cr>"] = actions.select_default + actions.center,
          ["<Tab>"] = function() end,
          ["<S-Tab>"] = function() end,
        },
        n = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
        },
      },
      -- preview = {
      --   hide_on_startup = true,
      -- },
      -- sort_mru = true,
      path_display = { "truncate" },
      multi_icon = "",
      -- The following lines were adapted from thanhvule0310/dotfiles
      prompt_prefix = "   ○  ",
      selection_caret = "  ",
      entry_prefix = "  ",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.5,
          results_width = 0.5,
        },
        width = 0.75,
        height = 0.75,
        preview_cutoff = 120,
      },
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
      buffers = {
        theme = "dropdown",
        previewer = false,
      },
    },
  }

  -- Cyan Telescope borders
  -- vim.cmd [[highlight TelescopeResultsBorder guifg=#56a5e5]]
  -- vim.cmd [[highlight TelescopePreviewBorder guifg=#56a5e5]]
  -- vim.cmd [[highlight TelescopePromptBorder guifg=#56a5e5]]

  local env = vim.env
  local builtin = require("telescope.builtin")

  local function get_start_dir()
    local path = vim.fn.expand("%:p")
    -- If the picker was opened in any of the Nvim config files,
    -- use ~/.config/nvim as the cwd instead of looking for a .git directory
    if path:match("^" .. vim.fn.stdpath("config")) then
      return vim.fn.stdpath("config")
    else
      return require("lspconfig/util").root_pattern(".git")(path)
    end
  end

  local function find_files()
    builtin.find_files {
      cwd = "~",
    }
  end

  local function project_search()
    local args = {
      cwd = get_start_dir(),
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
      search_dirs = { "/home/jonas/Desktop/Inacon/Kurse", inacon_dir .. "/Automation" },
    }
  end

  local function find_nvim_plugins()
    builtin.find_files {
      prompt_title = "Find Neovim Plugin Files",
      search_dirs = { "~/Desktop/NeovimPlugins" },
    }
  end

  local function grep_git_root(grep_fn)
    return function()
      grep_fn {
        cwd = get_start_dir(),
      }
    end
  end

  local function switch_git_branches()
    local ok = pcall(builtin.git_branches)
    if not ok then
      local x = vim.fn.getcwd()
      print(x .. " is not a git directory")
    end
  end

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
  end

  map("<leader>gb", switch_git_branches, "switch [g]it [b]ranches")
  map("<leader>fs", "<cmd>Telescope resume<cr>", "telescope re[s]ume")
  map("<leader>ff", "<cmd>Telescope smart_open<cr>", "telescope smart open")
  map("<leader>fi", find_inacon, "[f]ind in [I]nacon files")
  -- map("<leader>fp", project_search, "Find in Project")
  map("<leader>fv", find_nvim_plugins, "[f]ind in n[v]im plugins")
  map(KB["telescope.find_config"], M.find_config, "[f]ind in Neovim [c]onfig files")
  -- map("<leader>fo", require("telescope").extensions.recent_files.pick, "telescope Find Old files")
  -- map("<leader>fo", builtin.oldfiles, "telescope Find Old files")
  -- Requires ripgrep to be installed (sudo apt install ripgrep)
  -- map("<leader>fg", grep_git_root(builtin.live_grep), "telescope Find with ripGrep")
  map("<leader>fw", grep_git_root(builtin.grep_string), "[f]ind [w]ord under cursor")

  map("<leader>fb", builtin.buffers, "[f]ind [b]uffers")
  map("<leader>fh", builtin.help_tags, "[f]ind [h]elptags")
  map("<leader>fl", builtin.lsp_document_symbols, "[f]ind [L]SP document symbols")
  map("<leader>fq", builtin.quickfix, "[f]ind in [q]uickfix list")
  map("<leader>fk", builtin.keymaps, "[f]ind in [k]eymaps")
  map("<leader>fn", builtin.lsp_references, "[f]ind LSP refere[n]ces")
end

return M
