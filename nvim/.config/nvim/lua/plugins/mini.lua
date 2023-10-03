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
      },
    }

    -- Confirm file system actions on save, see https://github.com/echasnovski/mini.nvim/issues/391
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function()
        vim.schedule(function()
          vim.api.nvim_buf_set_option(0, "buftype", "acwrite")
          vim.api.nvim_buf_set_name(0, require("mini.files").get_fs_entry(0, 1).path)
          vim.api.nvim_create_autocmd("BufWriteCmd", {
            buffer = 0,
            callback = function()
              require("mini.files").synchronize()
            end,
          })
        end)
      end,
    })

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
