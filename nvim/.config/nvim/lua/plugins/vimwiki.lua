return {
  "vimwiki/vimwiki",
  branch = "dev",
  -- keys = "<leader>x",
  config = function()
    vim.g.vimwiki_list = {
      {
        template_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/vimwiki/autoload/",
        syntax = "markdown",
        ext = ".md",
      },
    }
    vim.g["vimwiki_global_ext"] = 0
    -- doesn't seem to work, use syntax file instead
    -- vim.g["vimwiki_listsyms"] = "☒⊡⬕"
    vim.keymap.set("n", "<leader>x", "<Plug>VimwikiIndex")
  end,
}
