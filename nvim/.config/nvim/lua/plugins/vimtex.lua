return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    vim.g.vimtex_view_method = "zathura"
    -- vim.cmd("autocmd User VimtexEventInitPost VimtexCompile")
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventInitPost",
      callback = function()
        vim.keymap.set("n", "<leader>c", vim.cmd.VimtexCompile, { buffer = true })
      end,
    })
  end,
}
