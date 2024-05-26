local function setup_mini_ai()
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
end

local function setup_mini_visits()
  require("mini.visits").setup()
  local map_vis = function(keys, call, desc)
    local rhs = "<Cmd>lua MiniVisits." .. call .. "<CR>"
    vim.keymap.set("n", keys, rhs, { desc = desc })
  end

  map_vis("<leader>vv", "add_label()", "Add label")
  map_vis("<leader>vV", "remove_label()", "Remove label")
  map_vis("<leader>vl", 'select_label("", "")', "Select label (all)")
  map_vis("<leader>vL", "select_label()", "Select label (cwd)")
end

return {
  "echasnovski/mini.nvim",
  config = function()
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
          pcall(function()
            vim.api.nvim_buf_set_name(0, require("mini.files").get_fs_entry(0, 1).path)
          end)
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

    setup_mini_ai()
    setup_mini_visits()
    require("mini.move").setup(require("config").get_effective_config("mini-move"))
    require("mini.operators").setup()
  end,
}
