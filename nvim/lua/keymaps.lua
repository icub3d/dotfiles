local remap = require('remap')
local nnoremap = remap.nnoremap
local vnoremap = remap.vnoremap
local inoremap = remap.vnoremap

-- nvim-tree
nnoremap('<leader>dt', ':NvimTreeToggle<cr>')

-- telescope
nnoremap('<leader>ff', "<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>")
nnoremap('<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap('<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap('<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
nnoremap('<leader>fk', ":Telescope keymaps<cr>")

nnoremap('gb', '<C-o>')

-- vim-test
nnoremap('<leader>tt', ":TestNearest -strategy=neovim<cr>")
nnoremap('<leader>tf', ":TestFile -strategy=neovim<cr>")
nnoremap('<leader>ts', ":TestSuite -strategy=neovim<cr>")
nnoremap('<leader>tl', ":TestLast -strategy=neovim<cr>")
nnoremap('<leader>tv', ":TestVisit -strategy=neovim<cr>")

-- base64 encode/decode
vnoremap('<leader>bd', "c<c-r>=system('base64 --decode', @\")<cr><esc>")
vnoremap('<leader>be', "c<c-r>=system('base64', @\")<cr><esc>")

-- window navigation
nnoremap("<leader>e", ":Lex 30<cr>")
nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")
nnoremap("<C-M-h>", ":vertical resize -2<cr>")
nnoremap("<C-M-l>", ":vertical resize +2<cr>")
nnoremap("<C-M-k>", ":resize -2<cr>")
nnoremap("<C-M-j>", ":resize +2<cr>")

-- Visual --
-- Stay in indent mode
vnoremap("<", "<gv")
vnoremap(">", ">gv")
