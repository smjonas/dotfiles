return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup {
      ignore_missing = false,
      plugins = {
        presets = {
          operators = false,
          motions = false,
          text_objects = false,
          windows = false,
          nav = false,
          z = false,
          g = false,
        },
      },
      -- triggers_blacklist = {
      --   i = { "i", "j", "k" },
      --   n = { "i", "z" },
      --   c = { "i" },
      -- },
    }
    wk.add {
      { "<leader>c", group = "custom commands" },
      {
        "<leader>cw",
        function()
          require("global_settings").toggle("remove_trailing_whitespace")
        end,
        desc = "Toggle removing trailing whitespace",
      },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
    }
  end,
}
