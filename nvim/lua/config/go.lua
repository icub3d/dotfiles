return function()
  local remap = require('remap')
  local nnoremap = remap.nnoremap

  require('go').setup()
  nnoremap('<leader>cr', ":GoCoverage<CR>")
  nnoremap('<leader>ct', ":GoCoverage -t<CR>")
  nnoremap('<leader>r', ":GoRun<CR>")
  nnoremap('<leader>ta', ":GoTest<CR>")
  nnoremap('<leader>tf', ":GoTestFile<CR>")
  nnoremap('<leader>tu', ":GoTestFunc<CR>")
  nnoremap('<leader>tp', ":GoTestPkg<CR>")
end
