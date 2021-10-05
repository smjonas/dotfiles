vim.g.coq_settings = {
  auto_start = true,
  keymap = { jump_to_mark = "<c-p>" },
  display = {
    pum = { source_context = { " [", "] " } },
    icons = { mode = "none" },
    ghost_text = { enabled = false }
  },
  clients = {
    buffers = { weight_adjust = 1.7 },
    snippets = { weight_adjust = 1.5 },
    lsp = { weight_adjust = -1.5 },
    tree_sitter = { weight_adjust = -1.7 }
  }
}
