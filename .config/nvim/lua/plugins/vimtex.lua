return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    -- vim.cmd("autocmd User VimtexEventInitPost VimtexCompile")
    vim.keymap.set("n", "<leader>c", vim.cmd.VimtexCompile, { buffer = true })
  end,
}
