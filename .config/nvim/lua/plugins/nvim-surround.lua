require("nvim-surround").setup {
  aliases = {
    ["b"] = { ")", "]" },
  },
}

-- Surround the current line with a pretty_print statement
vim.keymap.set("n", "<C-p>", "<cmd>norm yssp<cr>", {})

local vimwiki = {
  -- word + ysiwl => [word](https://github.com/current_clipboard_contents)
  l = {
    add = function()
      local clipboard = vim.fn.getreg("+"):gsub("^[%s\n]*(.-)[%s\n]*$", "%1")
      if clipboard:find("\n") then
        vim.notify("URL must not contain newline characters", vim.log.levels.WARN)
      else
        return {
          { "[" },
          { "](" .. clipboard .. ")" },
        }
      end
    end,
    find = "%b[]%b()",
    delete = "^(%[)().-(%]%b())()$",
    change = {
      target = "^()()%b[]%((.-)()%)$",
      replacement = function()
        local clipboard = vim.fn.getreg("+"):gsub("^[%s\n]*(.-)[%s\n]*$", "%1")
        if clipboard:find("\n") then
          vim.notify("URL must not contain newline characters", vim.log.levels.WARN)
        else
          return {
            { "" },
            { clipboard },
          }
        end
      end,
    },
  },
  ["*"] = {
    add = { "**", "**" },
    find = "%*%*.-%*%*",
    delete = "^(%*%*?)().-(%*%*?)()$",
    change = {
      target = "^(%*%*?)().-(%*%*?)()$",
    },
  },
}

local custom_surrounds = {
  vimwiki = vimwiki,
  markdown = vimwiki,
  lua = {
    p = {
      add = { "vim.pretty_print(", ")" },
      find = "vim%.pretty_print%b()",
      delete = "^(vim%.pretty_print%()().-(%))()$",
    },
  },
  go = {
    p = {
      add = { "fmt.Println(", ")" },
      find = "fmt%.Println%b()",
      delete = "^(fmt%.Println%()().-(%))()$",
    },
  },
}

local group = vim.api.nvim_create_augroup("custom_surrounds", {})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "*",
  callback = function(opts)
    local surrounds = custom_surrounds[opts.match]
    if surrounds then
      require("nvim-surround").buffer_setup { surrounds = surrounds }
    end
  end,
})