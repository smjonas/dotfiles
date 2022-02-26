local M = {}

local setup_mappings = function()
  local map = require("utils").map
  -- DAP debug
  map("n", "<leader>db", "<cmd>lua require('osv').run_this()<cr>")
  map("n", "<leader>dh", "<cmd>lua require('dap').toggle_breakpoint()<cr>")
  map("n", "<c-s-j>", "<cmd>lua require('dap').step_over()<cr>")
  map("n", "<c-s-k>", "<cmd>lua require('dap').step_out()<cr>")
  map("n", "<c-s-l>", "<cmd>lua require('dap').step_into()<cr>")
  -- DAP next
  map("n", "<leader>dn", "<cmd>lua require('dap').continue()<cr>")
end

local dap = require("dap")

-- samuraiRed from kanagawa theme
vim.cmd("highlight _Red guifg=#E82424")
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "_Red", linehl = "", numhl = "" })
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
    host = function()
      local value = vim.fn.input("Host [127.0.0.1]: ")
      if value ~= "" then
        return value
      end
      return "127.0.0.1"
    end,
    port = function()
      local val = tonumber(vim.fn.input("Port: "))
      assert(val, "Please provide a port number")
      return val
    end,
  },
}

dap.adapters.nlua = function(callback, config)
  callback { type = "server", host = config.host, port = config.port }
end

setup_mappings()
return M
