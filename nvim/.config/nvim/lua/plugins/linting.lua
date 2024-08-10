return {
  "mfussenegger/nvim-lint",
  ft = "python",
  config = function()
    require("lint").linters_by_ft = {
      python = { "mypy" },
    }
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      pattern = "*.py",
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
