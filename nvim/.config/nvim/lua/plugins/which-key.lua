return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup {
      ignore_missing = true,
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
            vim.g.remove_trailing_whitespace = not vim.g.remove_trailing_whitespace
            print(
              "Removing trailing whitespace: "
                .. (vim.g.remove_trailing_whitespace == true and "on" or "off")
            )
          end,
          "Toggle removing trailing whitespace",
        },
      },
    }
  end,
}
