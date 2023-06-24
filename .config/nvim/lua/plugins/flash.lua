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
    -- Use a label for the nearest match
    highlight = { label = { current = true } },
    jump = { autojump = true },
    modes = { char = { enabled = false } },
  },
  keys = {
    { "s", mode = { "n" }, jump_forward },
    { "S", mode = { "n" }, jump_backward },
    { "z", mode = { "o" }, jump_forward },
  },
}
