return {
    "danymat/neogen",
    cmd = "Neogen",
    config = function()
      require("neogen").setup {
        enabled = true,
      }
      vim.keymap.set("n", "<leader>nf", function()
        require("neogen").generate {}
      end, { silent = true })
    end,
  }
