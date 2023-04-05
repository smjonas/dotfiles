return {
  "folke/which-key.nvim",
  config = function()
    require("which-key").setup {
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
      triggers_blacklist = {
        i = { "i", "j", "k" },
      },
    }

    require("which-key").register({
      c = {
        name = "custom commands",
        w = {
          function()
            vim.g.remove_trailing_whitespace = not vim.g.remove_trailing_whitespace
            print(
              "Removing trailing whitespace: "
                .. (vim.g.remove_trailing_whitespace == true and "on" or "off")
            )
          end,
          "Toggle remove trailing whitespace",
        },
      },
    }, { prefix = "<leader>" })
  end,
}
