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
    }
  end,
}
