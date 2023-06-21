local jump_forward = function()
  require("flash").jump {
    search = { forward = true, wrap = false, multi_window = false },
  }
end

local jump_backward = function()
  require("flash").jump {
    search = { forward = false, wrap = false, multi_window = false },
  }
end

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    highlight = { label = { current = true } },
  },
  keys = {
    { "s", mode = { "n" }, jump_forward },
    { "S", mode = { "n" }, jump_backward },
    { "z", mode = { "o" }, jump_forward },
  },
}
