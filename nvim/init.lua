require('configs')
require('plugins')
require('theme')
require('keymaps')

-- reload on config changes
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("packer_compile_on_config_save", { clear = true }),
  pattern = { "*/nvim/*" },
  command = "source % | PackerCompile",
})


-- Update tmux status on save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("tmux_status_tracker_save", { clear = true }),
  pattern = { "*" },
  command = "silent exec '!tmux_status_tracker_save >/dev/null'",
})
