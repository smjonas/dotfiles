local M = {
  "lewis6991/gitsigns.nvim",
}

M.config = function()
  require("gitsigns").setup {
    on_attach = function()
      local gitsigns = package.loaded.gitsigns
      local map = vim.keymap.set
      map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[gitsigns] Stage hunk" })
      map("n", "<leader>hu", gitsigns.reset_hunk, { desc = "[gitsigns] Unstage hunk" })
      map("n", "<leader>ha", gitsigns.stage_buffer, { desc = "[gitsigns] Stage buffer" })
      map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "[gitsigns] Preview hunk" })
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
