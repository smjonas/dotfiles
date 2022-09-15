-- Global settings
vim.g.snippet_engine = "luasnip"
pcall(vim.cmd, "colorscheme github_dark")

local plugins = require("plugins")

-- local function command_preview(opts, _, _)
--   vim.cmd("norm i " .. opts.args)
--   return 0
-- end
--
-- vim.api.nvim_create_user_command("Test", function() end, { preview = command_preview, nargs = 1 })
--
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

local function register_plugins(plugins_, use)
  local dependencies = {}
  for _, plugin in ipairs(plugins_) do
    local settings = {}
    if type(plugin) == "table" then
      local requires = plugin.requires
      if type(requires) == "string" then
        requires = { requires }
      end
      for _, req in ipairs(requires) do
        if not vim.tbl_contains(dependencies, req) then
          table.insert(dependencies, req)
        end
      end
      plugin = plugin[1]
      settings.requires = requires
    end

    local plugin_name = vim.split(plugin, "/")
    plugin_name = plugin_name[#plugin_name]
    settings = vim.tbl_deep_extend("force", plugins.settings[plugin_name] or {}, settings)
    settings[1] = plugin
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
    -- Color schemes
    use(require("colorschemes"))
    if PackerBootstrap then
      require("packer").sync()
    end
  end,
}
