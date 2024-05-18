local M = {}

M.config = {
  ["mini-move"] = {
    default_config = {
      mappings = {
        left = "<M-h>",
        right = "<M-j>",
        down = "<M-k>",
        up = "<M-l>",
        line_left = "<M-h>",
        line_right = "<M-j>",
        line_down = "<M-k>",
        line_up = "<M-l>",
      },
    },
    piantor_config = {
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
    apply_config = function(config)
      require("mini-move").setup(config)
    end,
  },
}

M.get_effective_config = function(key)
  assert(M.config[key], "Invalid key: " .. key)
  local effective_config_key = GlobalSettings.override_mappings_for_piantor and "piantor_config"
    or "default_config"
  return M.config[key][effective_config_key]
end

return M
