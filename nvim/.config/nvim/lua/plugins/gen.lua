return {
  "smjonas/gen.nvim",
  config = function()
    -- need to use :, see https://github.com/David-Kunz/gen.nvim/issues/16
    vim.keymap.set({ "n", "v" }, "<leader>gn", ":Gen<cr>")
  end
}
