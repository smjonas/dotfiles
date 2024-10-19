local M = {}

---@class GlobalSettings
---@field remove_trailing_whitespace boolean
---@field use_piantor_mappings boolean

local settings = {
  remove_trailing_whitespace = { default = true, desc = "Remove trailing whitespace on save" },
  use_piantor_mappings = {
    default = function()
      local obj = vim.system({ "lsusb", "-d", "beeb:0001" }, { text = true }):wait()
      local piantor_plugged_in = obj.stdout ~= ""
      if piantor_plugged_in then
        print("[global settings] ⌨️ piantor keyboard plugged in")
      else
        print("[global settings] 🔌 piantor keyboard not plugged in")
      end
      return piantor_plugged_in
    end,
    desc = "Use mappings for piantor keyboard",
  },
}

M.apply_defaults = function()
  GlobalSettings = {}
  for setting, value in pairs(settings) do
    GlobalSettings[setting] = type(value.default) == "boolean" and value.default or value.default()
  end
  require("mappings").init(GlobalSettings.use_piantor_mappings)
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
