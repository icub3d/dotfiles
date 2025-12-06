return {
  "sindrets/diffview.nvim",
  laxy = false,
  config = function()
    vim.keymap.set('n', '<leader>d', ':DiffviewOpen<cr>', { desc = 'Diffview' })
  end
}
