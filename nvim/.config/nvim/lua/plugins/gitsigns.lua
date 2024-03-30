local M = {
  "lewis6991/gitsigns.nvim",
}

M.config = function()
  require("gitsigns").setup {
    on_attach = function()
      local gitsigns = package.loaded.gitsigns
      local map = vim.keymap.set
      map("n", "<leader>ga", gitsigns.stage_hunk, { desc = "[g]it stage / [a]dd hunk" })
      map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[g]it unstage / [r]emove hunk" })
      map("n", "<leader>ge", gitsigns.stage_buffer, { desc = "[g]it stage [e]ntire buffer" })
      map("n", "<leader>gg", gitsigns.preview_hunk, { desc = '[g]it preview / "[g]et" hunk' })
      -- Navigation
      local next_chunk = "[c"
      local prev_chunk = "]c"
      for _, direction in ipairs { next_chunk, prev_chunk } do
        map("n", direction, function()
          if vim.wo.diff then
            return direction
          end
          vim.schedule(function()
            if direction == next_chunk then
              gitsigns.next_hunk()
            else
              gitsigns.prev_hunk()
            end
          end)
          return "<Ignore>"
        end, { expr = true })
      end
    end,
  }
end

return M
