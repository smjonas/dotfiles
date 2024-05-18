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
    wk.register {
      ["<leader>f"] = { name = "+find" },
      ["<leader>g"] = { name = "+git" },
      ["<leader>c"] = {
        name = "custom commands",
        w = {
          function()
            require("global_settings").toggle("remove_trailing_whitespace")
          end,
          "Toggle removing trailing whitespace",
        },
      },
    }
  end,
}
