return function()
  local remap = require('remap')
  local nnoremap = remap.nnoremap

  require('go').setup()
  nnoremap('<leader>ccr', ":GoCoverage<CR>")
  nnoremap('<leader>cct', ":GoCoverage -t<CR>")
  nnoremap('<leader>cr', ":GoRun<CR>")
  nnoremap('<leader>cta', ":GoTest<CR>")
  nnoremap('<leader>ctf', ":GoTestFile<CR>")
  nnoremap('<leader>ctu', ":GoTestFunc<CR>")
  nnoremap('<leader>ctp', ":GoTestPkg<CR>")
end
