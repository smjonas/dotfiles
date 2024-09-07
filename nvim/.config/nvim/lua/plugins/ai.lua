return {
  "frankroeder/parrot.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("parrot").setup {
      providers = {
        anthropic = {
          api_key = os.getenv("ANTHROPIC_API_KEY"),
        },
      },
      hooks = {
        UnitTests = function(prt, params)
          local template = [[
        Have a look at the following code from {{filename}}:

        ```{{filetype}}
        {{filecontent}}
        ```

        Please respond by writing table driven unit tests for the code above.
        ]]
          local model_obj = prt.get_model("command")
          prt.logger.info("Creating unit tests for selection with model: " .. model_obj.name)
          prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
        end,
      },
    }
    vim.keymap.set("n", "<leader>at", "<cmd>PrtUnitTests<cr>", { desc = "Create unit tests" })
  end,
}
