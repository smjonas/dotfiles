return {
  "windwp/nvim-autopairs",
  config = function()
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    require("nvim-autopairs").setup {
      break_undo = false,
      disable_filetype = { "TelescopePrompt", "vim", "tex" },
      -- Insert brackets after selecting function from cmp
      require("cmp").event:on(
        "confirm_done",
        cmp_autopairs.on_confirm_done {
          map_char = { tex = "" },
        }
      ),
    }
  end,
}
