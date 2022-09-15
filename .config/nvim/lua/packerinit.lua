--  separate env_patterns table: 12,6s

local plugin_settings = require("plugin_settings")
local potentially_disabled_plugins = {}

local plugin_list = {
  "wbthomason/packer.nvim",
  "kylechui/nvim-surround",
  {
    "~/Desktop/NeovimPlugins/inc-rename.nvim",
    requires = "~/Desktop/NeovimPlugins/dressing.nvim",
  },
  "~/Desktop/NeovimPlugins/live-command.nvim",
  "smjonas/live-tests-busted.nvim",
  "~/Desktop/NeovimPlugins/snippet-converter.nvim",
  {
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      module = "nvim-treesitter-textobjects",
    },
  },
  "danymat/neogen",
  { "nvim-lualine/lualine.nvim", requires = "kyazdani42/nvim-web-devicons" },
  { "neovim/nvim-lspconfig", requires = "folke/lua-dev.nvim" },
  "glepnir/lspsaga.nvim",
  "ray-x/lsp_signature.nvim",
  { "jose-elias-alvarez/null-ls.nvim", requires = "nvim-lua/plenary.nvim" },
  { "williamboman/mason.nvim", requires = "williamboman/mason-lspconfig.nvim" },
  "j-hui/fidget.nvim",
  "SmiteshP/nvim-navic",
  { "mfussenegger/nvim-dap", requires = "jbyuki/one-small-step-for-vimkind" },
  { "lambdalisue/fern.vim", requires = "lambdalisue/fern-hijack.vim" },
  {
    "hrsh7th/nvim-cmp",
    requires = {
      "saadparwaiz1/cmp_luasnip",
      "max397574/cmp-greek",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
    },
  },
  { "L3MON4D3/LuaSnip", requires = "rafamadriz/friendly-snippets" },
  "SirVer/ultisnips",
  { "nvim-telescope/telescope.nvim", requires = "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", requires = "nvim-telescope/telescope.nvim" },
  { "smartpde/telescope-recent-files", requires = "nvim-telescope/telescope.nvim" },
  "mattn/emmet-vim",
  "alvan/vim-closetag",
  "lervag/vimtex",
  "NvChad/nvim-colorizer.lua",
  "vim-test/vim-test",
  "wellle/targets.vim",
  { "Julian/vim-textobj-variable-segment", requires = "kana/vim-textobj-user" },
  "inkarkat/vim-ReplaceWithRegister",
  "AndrewRadev/sideways.vim",
  "zirrostig/vim-schlepp",
  {
    "numToStr/Comment.nvim",
    requires = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  "windwp/nvim-autopairs",
  "rmagatti/auto-session",
  "ggandor/leap.nvim",
  "tpope/vim-fugitive",
  { "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" },
  "vimwiki/vimwiki",
  "iamcco/markdown-preview.nvim",
  "glacambre/firenvim",
  "luukvbaal/stabilize.nvim",
  "dstein64/vim-startuptime",
  "arp242/undofile_warn.vim",
  "tpope/vim-repeat",
  "lewis6991/impatient.nvim",
}

local disabled_plugins = {
  -- "inc-rename.nvim",
  -- "null-ls.nvim",
  -- "telescope.nvim",
  -- "diffview.nvim",
  -- "null-ls.nvim",
  --  "Comment.nvim",
  --  "LuaSnip",
  --  "auto-session",
  --  "cmp-buffer",
  --  "cmp-greek",
  --  "cmp-nvim-lsp",
  --  "cmp-path",
  --  "cmp_luasnip",
  -- "diffview.nvim",
  --  "emmet-vim",
  --  "fern.vim",
  --  "fidget.nvim",
  --  "firenvim",
  --  "github-nvim-theme",
  --  "impatient.nvim",
  --  "inc-rename.nvim",
  --  "leap.nvim",
  --  "live-command.nvim",
  --  "live-tests-busted.nvim",
  --  "lsp_signature.nvim",
  -- "lspsaga.nvim",
  -- "lualine.nvim",
  -- "markdown-preview.nvim",
  -- "mason.nvim",
  -- "neogen",
  -- "null-ls.nvim",
  -- "nvim-autopairs",
  -- "nvim-cmp",
  -- "nvim-colorizer.lua",
  -- "nvim-dap",
  -- "nvim-lspconfig",
  -- "nvim-navic",
  -- "nvim-surround",
  --  "nvim-treesitter",
  --  "sideways.vim",
  --  "snippet-converter.nvim",
  --  "stabilize.nvim",
  --  "targets.vim",
  --  "telescope-fzf-native.nvim",
  --  "telescope-recent-files",
  --  "telescope.nvim",
  --  "tokyonight-vim",
  -- "undofile_warn.vim",
  -- "vim-ReplaceWithRegister",
  -- "vim-closetag",
  -- "vim-fugitive",
  -- "vim-repeat",
  -- "vim-schlepp",
  -- "vim-startuptime",
  -- "vim-test",
  -- "vim-textobj-variable-segment",
  -- "vimtex",
}

local function command_preview(opts, _, _)
  vim.cmd("norm i " .. opts.args)
  return 0
end

vim.api.nvim_create_user_command("Test", function() end, { preview = command_preview, nargs = 1 })

local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  PackerBootstrap = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
end

local all_plugins = {}
local is_disabled = {}
local potentially_disabled_plugins = {}
local child_plugins = {}

local function get_plugin_settings(plugin)
  local plugin_name = vim.split(plugin, "/")
  plugin_name = plugin_name[#plugin_name]
  local settings = plugin_settings[plugin_name] or {}
  settings[1] = plugin

  -- Handle explicitly disabled plugins
  if vim.tbl_contains(disabled_plugins, plugin_name) then
    settings.cond = false
    is_disabled[plugin_name] = true
  end
  return settings, plugin_name, is_disabled[plugin_name]
end

local function register_plugins(plugins_, use)
  for _, plugin in ipairs(plugins_) do
    local requirements
    if type(plugin) == "table" then
      requirements = plugin.requires
      if type(requirements) == "string" then
        requirements = { requirements }
      end
      plugin = plugin[1]
    end
    local settings, name, disabled = get_plugin_settings(plugin)
    settings.requires = requirements

    use(settings)
    all_plugins[name] = true

    for _, requirement in ipairs(requirements or {}) do
      child_plugins[requirement] = true
      if disabled then
        -- Store the parent plugin
        potentially_disabled_plugins[requirement] = potentially_disabled_plugins[requirement] or {}
        table.insert(potentially_disabled_plugins[requirement], name)
      end
    end
  end
end

local function disable_inactive_plugins(use)
  local active_child_plugins = child_plugins
  for child_plugin, parent_plugins in pairs(potentially_disabled_plugins) do
    local should_disable = true
    -- Check if all parent plugins are also disabled
    for _, parent_plugin in ipairs(parent_plugins) do
      vim.pretty_print(parent_plugins)
      if not is_disabled[parent_plugin] then
        should_disable = false
        break
      end
    end
    local child_settings, name = get_plugin_settings(child_plugin)
    if should_disable then
      print("Disabling child plugin", child_plugin)
      child_settings.cond = false
      is_disabled[name] = true
      active_child_plugins[child_plugin] = false
    end
    use(child_settings)
  end
  register_plugins(vim.tbl_keys(active_child_plugins), use)
end

require("packer").startup {
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float {
          border = "single",
        }
      end,
    },
  },
  function(use)
    plugin_settings = vim.deepcopy(plugin_settings)
    register_plugins(plugin_list, use)
    -- Color schemes
    use(require("colorschemes"))
    disable_inactive_plugins(use)
    local count = vim.tbl_count(is_disabled)
    if count > 0 then
      print(
        ("Disabled plugins (%d/%d): %s"):format(
          vim.tbl_count(is_disabled),
          #vim.tbl_keys(all_plugins),
          vim.inspect(table.concat(vim.tbl_keys(is_disabled), ", "))
        )
      )
    end
    if PackerBootstrap then
      require("packer").sync()
    end
  end,
}
