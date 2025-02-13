require('configs')
require('plugins')
require('keymaps')

vim.o.autoread = true
local group = vim.api.nvim_create_augroup("my-group", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
  group = group,
})

vim.api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
  callback = function(data)
    local path = data.file:match("(.*[/\\])")
    os.execute("nu -c \"source \\$nu.env-path; source \\$nu.config-path; git-status-tracker-save \'" .. path .. "\'\"")
  end,
  pattern = { "*" },
  group = group,
})
