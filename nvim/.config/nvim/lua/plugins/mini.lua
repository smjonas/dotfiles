return {
  "echasnovski/mini.nvim",
  config = function()
    local ai = require("mini.ai")
    local spec = ai.gen_spec.treesitter

    require("mini.ai").setup {
      n_lines = 200,
      ai.setup {
        custom_textobjects = {
          f = spec { a = "@function.outer", i = "@function.inner" },
          c = spec { a = "@class.outer", i = "@class.inner" },
          i = spec { a = "@conditional.outer", i = "@conditional.inner" },
          a = spec { a = "@conditional.outer", i = "@parameter.inner" },
        },
      },
    }

    require("mini.files").setup {
      mappings = {
        go_in = "",
        go_in_plus = "L",
        go_out = "H",
        go_out_plus = "",
      }
    }

    vim.keymap.set("n", "<C-n>", function()
      if not MiniFiles.close() then
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
      end
    end)

    require("mini.operators").setup()
    require("mini.comment").setup()
    require("mini.move").setup()
  end,
}
