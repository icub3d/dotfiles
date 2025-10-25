-- Netrw
vim.keymap.set("n", "<leader>fv", vim.cmd.Ex)

-- Go back
vim.keymap.set("n", "gb", "<C-o>")

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
