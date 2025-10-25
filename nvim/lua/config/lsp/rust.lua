vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = "clippy",
      },
      diagnostics = {
        enable = true,
      }
    }
  }
})

vim.lsp.enable('rust_analyzer')
