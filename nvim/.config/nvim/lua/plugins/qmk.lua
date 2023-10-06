return {
  "codethread/qmk.nvim",
  config = function()
    require("qmk").setup {
      name = "LAYOUT_split_3x6_3",
      layout = {
        "x x x x x x _ x x x x x x",
        "x x x x x x _ x x x x x x",
        "x x x x x x _ x x x x x x",
        "_ _ _ _ _ _ _ _ _ _ _ _ _",
        "_ _ _ x x x _ x x x _ _ _",
      },
      comment_preview = {
        keymap_overrides = {
          XXX = "   ",
          KC_KP_PLUS = "+",
          KC_KP_MINUS = "-",
          KC_KP_EQUAL = "=",
        },
      },
    }
  end,
}
