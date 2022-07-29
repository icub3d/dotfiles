local remap = require('remap')
local nnoremap = remap.nnoremap
local vnoremap = remap.vnoremap

nnoremap('<leader>ff', "<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>")
nnoremap('<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap('<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>")
nnoremap('<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")

nnoremap('gb', '<C-o>')

-- base64 encode/decode
vnoremap('<leader>bd', "c<c-r>=system('base64 --decode', @\")<cr><esc>")
vnoremap('<leader>be', "c<c-r>=system('base64', @\")<cr><esc>")
