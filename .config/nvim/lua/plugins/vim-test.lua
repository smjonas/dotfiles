return {
  "vim-test/vim-test",
  ft = "python",
  config = function()
    -- Activate python virtual env, then run current test file in new window
    vim.g["test#python#pytest#executable"] = "source $INACON_VENV_ACTIVATE && pytest -rT -vv"
    vim.g["test#strategy"] = "neovim"
    vim.g["test#neovim#term_position"] = "vertical 80"

    -- Run tests
    map("n", "<leader>t", "<cmd>TestFile<cr>")
    -- Run nearest test
    map("n", "<leader>n", "<cmd>TestNearest<cr>")
  end,
}
