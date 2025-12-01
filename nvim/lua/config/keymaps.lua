-- Netrw
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Go back
vim.keymap.set("n", "gb", "<C-o>")

-- remove line numbers
vim.keymap.set('n', '<leader>n', function()
    if vim.o.relativenumber then
      vim.o.relativenumber = false
      vim.o.number = false
      vim.o.statuscolumn = ''
    else
      vim.o.relativenumber = true
      vim.o.number = true
      vim.o.statuscolumn = '%{v:lnum} %{v:relnum}'
    end
  end,
  { noremap = true, silent = true, desc = "Toggle line numbers" })

-- copy/paste
vim.keymap.set('n', '<leader>cc', '"+yy',
  { noremap = true, silent = true, desc = 'Copy current line to system clipboard' })
vim.keymap.set('v', '<leader>cc', '"+y', { noremap = true, silent = true, desc = 'Copy selection to system clipboard' })
vim.keymap.set('n', '<leader>cp', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>cp', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })

-- : commands.
vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>", { noremap = true, silent = true, desc = "Update Source" })
vim.keymap.set("n", "<leader>w", ":write<CR>", { noremap = true, desc = "Save current file" })
vim.keymap.set("n", "<leader>q", ":quit<CR>", { noremap = true, desc = "Quit Neovim" })

-- base64 encode/decode
vim.keymap.set("v", '<leader>bud', "c<c-r>=trim(system('nu --stdin -c \"decode base64 --url | decode\"', @\"))<cr><esc>")
vim.keymap.set("v", '<leader>bue', "c<c-r>=trim(system('nu --stdin -c \"encode base64 --url\"', @\"))<cr><esc>")
vim.keymap.set("v", '<leader>bd', "c<c-r>=trim(system('nu --stdin -c \"decode base64 | decode\"', @\"))<cr><esc>")
vim.keymap.set("v", '<leader>be', "c<c-r>=trim(system('nu --stdin -c \"encode base64\"', @\"))<cr><esc>")

-- window navigation
vim.keymap.set("n", "<leader>e", ":Lex 30<cr>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-M-h>", ":vertical resize -2<cr>")
vim.keymap.set("n", "<C-M-l>", ":vertical resize +2<cr>")
vim.keymap.set("n", "<C-M-k>", ":resize -2<cr>")
vim.keymap.set("n", "<C-M-j>", ":resize +2<cr>")

-- Visual --
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
