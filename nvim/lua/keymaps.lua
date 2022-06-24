vim.api.nvim_set_keymap('n', '<C-p>',
  "<cmd>lua require('fzf-lua').files()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>',
  "<cmd>lua require('fzf-lua').buffers()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gb', '<C-o>', { noremap = true, silent = true })
