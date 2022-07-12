require('configs')
require('plugins')
require('theme')
require('keymaps')

-- reload on config changes
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "*/nvim/*" },
  command = "source % | PackerCompile",
})
