local plugins = require("plugins")

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
local disabled_plugins = {}

local function get_plugin_settings(plugin)
  local plugin_name = vim.split(plugin, "/")
  plugin_name = plugin_name[#plugin_name]
  local settings = plugins.settings[plugin_name] or {}
  settings[1] = plugin

  -- Disable explicitly disabled plugins
  local is_disabled = vim.tbl_contains(plugins.disabled, plugin_name)
  if is_disabled then
    settings.cond = false
    table.insert(disabled_plugins, plugin_name)
  end
  return settings, plugin_name, is_disabled
end

local function register_plugins(plugins_, use)
  local dependencies = {}
  for _, plugin in ipairs(plugins_) do
    local requirements = {}
    if type(plugin) == "table" then
      requirements = plugin.requires
      if type(requirements) == "string" then
        requirements = { requirements }
      end
      for _, req in ipairs(requirements) do
        if not vim.tbl_contains(dependencies, req) then
          table.insert(dependencies, req)
        end
      end
      plugin = plugin[1]
    end

    local settings, name, is_disabled = get_plugin_settings(plugin)
    all_plugins[name] = true

    for _, requirement in ipairs(requirements) do
      local req_settings, req_name = get_plugin_settings(requirement)
      -- Also disable all dependencies
      if is_disabled and not all_plugins[req_name] then
        req_settings.cond = false
        use(req_settings)
        table.insert(disabled_plugins, req_name)
      end
      all_plugins[req_name] = true
    end
    use(settings)
  end
  if not vim.tbl_isempty(dependencies) then
    register_plugins(dependencies, use)
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
    register_plugins(plugins.list, use)
    print(
      ("Disabled plugins: (%d/%d) %s"):format(
        #disabled_plugins,
        #vim.tbl_keys(all_plugins),
        vim.inspect(table.concat(disabled_plugins, ", "))
      )
    )
    -- Color schemes
    use(require("colorschemes"))
    if PackerBootstrap then
      require("packer").sync()
    end
  end,
}
