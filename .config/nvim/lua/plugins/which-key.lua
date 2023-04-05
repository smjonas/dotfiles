return {
  "folke/which-key.nvim",
  config = function()
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
