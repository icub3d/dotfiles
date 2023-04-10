local remap = require('remap')
local nnoremap = remap.nnoremap
local vnoremap = remap.vnoremap
local tnoremap = remap.tnoremap

-- floaterm
nnoremap('<leader>tn', ":FloatermNew<CR>")
nnoremap('<leader>tp', ":FloatermNew! python %<CR>")
vnoremap('<leader>tp', ":'<,'>FloatermNew! python<CR>")
tnoremap('<leader>tn', "<C-\\><C-n>:FloatermNew<CR>")
nnoremap('<leader>t>', ":FloatermNext<CR>")
tnoremap('<leader>t>', '<C-\\><C-n>:FloatermNext<CR>')
nnoremap('<leader>t<', ":FloatermPrev<CR>")
tnoremap('<leader>t<', '<C-\\><C-n>:FloatermPrev<CR>')
nnoremap('<leader>tt', ":FloatermToggle<CR>")
tnoremap('<leader>tt', '<C-\\><C-n>:FloatermToggle<CR>')

-- LSP
nnoremap('<leader>lr', "<cmd>lua vim.lsp.buf.rename()<CR>")
nnoremap('<leader>lx', ":LspRestart<CR>")
nnoremap('<leader>lf', "<cmd>lua vim.lsp.buf.format()<CR>")

-- Go back
nnoremap('gb', '<C-o>')

-- base64 encode/decode
vnoremap('<leader>bd', "c<c-r>=system('base64 --decode', @\")<cr><esc>")
vnoremap('<leader>be', "c<c-r>=system('base64 -w0', @\")<cr><esc>")

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
vnoremap("<", "<gv")
vnoremap(">", ">gv")

-- Prettier --
vnoremap("^", 'vi{:! prettier --parser html --stdin-filepath<CR>vi{>')
