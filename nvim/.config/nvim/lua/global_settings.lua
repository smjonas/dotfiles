local M = {}

---@class GlobalSettings
---@field remove_trailing_whitespace boolean
---@field override_mappings_for_piantor boolean

local settings = {
  remove_trailing_whitespace = { default = true, desc = "Remove trailing whitespace on save" },
  override_mappings_for_piantor = { default = true, desc = "Override mappings for piantor" },
}

M.apply_defaults = function()
  GlobalSettings = {}
  for setting, value in pairs(settings) do
    GlobalSettings[setting] = value.default
  end
  require("piantor").apply_mappings(GlobalSettings.override_mappings_for_piantor)
end

M.toggle = function(setting)
  if setting ~= "remove_trailing_whitespace" then
    vim.notify("Invalid setting: " .. setting)
  end
  GlobalSettings[setting] = not GlobalSettings[setting]
  vim.notify(settings[setting].desc .. ": " .. (GlobalSettings[setting] and "off" or "on"))
end

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace on save",
  callback = function()
    if GlobalSettings.remove_trailing_whitespace then
      vim.cmd([[%s/\s\+$//e]])
    end
  end,
})

return M
