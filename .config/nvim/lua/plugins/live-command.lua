return {
  "smjonas/live-command.nvim",
  dependencies = { "tpope/vim-abolish" },
  -- dev = true,
  -- branch = "inline_highlights",
  -- "smjonas/live-command.nvim",
  config = function()
    local commands = {
      Norm = { cmd = "norm" },
      G = { cmd = "g" },
      D = { cmd = "d" },
      Reg = {
        cmd = "norm",
        args = function(opts)
          return (opts.count == -1 and "" or opts.count) .. "@" .. opts.args
        end,
        range = "",
      },
      LSubvert = { cmd = "Subvert" },
      S = { cmd = "substitute" },
    }
    require("live-command").setup {
      debug = true,
      defaults = {
        --   -- hl_groups = { deletion = false },
        enable_highlighting = false,
        --   -- interline_highlighting = false,
        -- },
      },
      commands = commands,
    }
  end,
}
