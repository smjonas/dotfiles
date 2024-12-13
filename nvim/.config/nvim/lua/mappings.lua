local M = {}

local mappings = {
  ["diagnostic.next"] = { default = "<C-k>", piantor = "<C-i>" },
  ["diagnostic.prev"] = { default = "<C-j>", piantor = "<C-m>" },
  ["quickfix.next"] = { default = "<leader>k", piantor = "<leader>e" },
  ["quickfix.prev"] = { default = "<leader>j", piantor = "<leader>l" },
  ["goto.definition"] = { default = "<leader>gd", piantor = "<leader>gt" },
  ["edit.init"] = { default = "<leader>rc", piantor = "<leader>ri" },
  ["insert.left"] = { default = "<C-h>", piantor = "<C-m>" },
  ["insert.right"] = { default = "<C-l>", piantor = "<C-i>" },
  ["insert.up"] = { default = "<C-j>", piantor = "<C-e>" },
  ["insert.down"] = { default = "<C-k>", piantor = "<C-n>" },
  ["telescope.find_config"] = { default = "<leader>fu", piantor = "<leader>fu" },
  -- nvim-cmp
  ["cmp.previous"] = { default = "<C-p>", piantor = "<C-e>" },
  -- mini
  ["mini.move"] = {
    default = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
    piantor = {
      mappings = {
        left = "<M-m>",
        right = "<M-i>",
        down = "<M-n>",
        up = "<M-e>",
        line_left = "<M-m>",
        line_right = "<M-i>",
        line_down = "<M-n>",
        line_up = "<M-e>",
      },
    },
  },
  ["mini.files"] = {
    default = {
      mappings = {
        go_in = "L",
        go_in_plus = "",
        go_out = "H",
        go_out_plus = "",
      },
    },
    piantor = {
      mappings = {
        go_in = "I",
        go_in_plus = "",
        go_out = "M",
        go_out_plus = "",
      },
    },
  },
}

M.init = function(piantor_mappings)
  KB = {}
  for mapping, keys in pairs(mappings) do
    KB[mapping] = keys[piantor_mappings and "piantor" or "default"]
  end
end

return M
