return {
  "luukvbaal/stabilize.nvim",
  config = function()
    -- Workaround for error that occurs when using vim-fugitive and stabililize.nvim
    -- at the same time. See https://github.com/luukvbaal/stabilize.nvim/issues/6.
    vim.cmd([[
    autocmd WinNew * lua win=vim.api.nvim_get_current_win() vim.defer_fn(
    \function() vim.api.nvim_set_current_win(win) end, 50
    \)
    ]])
    require("stabilize").setup()
  end,
}
