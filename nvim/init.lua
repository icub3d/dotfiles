require('keymaps')
require('configs')
require('plugins')
-- require('plugins')
-- require('theme')


-- Update tmux status on save
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = vim.api.nvim_create_augroup('tmux_status_tracker_save', { clear = true }),
  pattern = { '*' },
  command = "silent exec '!tmux_status_tracker_save >/dev/null'",
})
