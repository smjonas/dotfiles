local plugins = require("plugin_list")
local plugin_settings = require("plugin_settings")

local function command_preview(_, _, _)
  vim.g.kek = vim.api.nvim_get_mode()
  vim.cmd("norm A = 'hey")
  return 2
end

vim.api.nvim_create_user_command("Test", function() end, { preview = command_preview, nargs = 0 })

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
local disabled = {}
local child_plugin_to_parent = {}

local function get_short_name(plugin)
  local plugin_name = vim.split(plugin, "/")
  return plugin_name[#plugin_name]
end

local function register_plugins(plugins_, use)
  local requirements = {}
  for _, plugin in ipairs(plugins_) do
    if type(plugin) == "table" then
      requirements = plugin.requires
      if type(requirements) == "string" then
        requirements = { requirements }
      end
      plugin = plugin[1]
      for _, child in ipairs(requirements) do
        if not child_plugin_to_parent[child] then
          child_plugin_to_parent[child] = {}
        end
        table.insert(child_plugin_to_parent[child], plugin)
      end
    end
    all_plugins[plugin] = true
  end

  for child, parents in pairs(child_plugin_to_parent) do
    for _, parent in ipairs(parents) do
      -- If the child plugin is disabled, also disable the parent (that sounds so wrong lol)
      local child_name = get_short_name(child)
      if vim.tbl_contains(plugins.disabled, child_name) then
        all_plugins[parent] = false
        all_plugins[child] = false
      else
        all_plugins[child] = true
      end
    end
  end

  for plugin, enabled in pairs(all_plugins) do
    local name = get_short_name(plugin)
    local is_enabled = enabled == true and not vim.tbl_contains(plugins.disabled, name)
    if is_enabled then
      local settings = plugin_settings[name] or {}
      settings[1] = plugin
      use(settings)
    else
      use { plugin, cond = false }
      table.insert(disabled, name)
    end
  end
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
    register_plugins(plugins.all, use)
    pcall(vim.cmd, "colorscheme tokyonight-moon")

    local count = vim.tbl_count(disabled)
    if count > 0 then
      vim.schedule(function()
        print(
          ("Disabled plugins (%d/%d): %s"):format(
            vim.tbl_count(disabled),
            #vim.tbl_keys(all_plugins),
            vim.inspect(table.concat(disabled, ", "))
          )
        )
      end)
    end
    if PackerBootstrap then
      require("packer").sync()
    end
  end,
}
