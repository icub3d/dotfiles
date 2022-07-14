local remap = require('remap')
local nnoremap = remap.nnoremap
nnoremap('<C-p>', "<cmd>lua require('fzf-lua').files()<CR>")
nnoremap('<C-b>', "<cmd>lua require('fzf-lua').buffers()<CR>")
nnoremap('gb', '<C-o>')
