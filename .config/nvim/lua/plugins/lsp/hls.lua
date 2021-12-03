local util = require("lspconfig/util")
local root_dir = util.root_pattern(
  ".git", -- also start language server in git project
  "*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml"
)

return { root_dir = root_dir }
