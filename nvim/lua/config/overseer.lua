return function()
  local overseer = require('overseer')
  overseer.setup({
    task_list = {
      direction = 'bottom',
      min_height = 10,
      max_height = 15,
      default_detail = 1,
    }
  })
  local remap = require('remap')
  local nnoremap = remap.nnoremap
  local build_and_run = function()
    overseer.open({ enter = false, direction = 'bottom' })
    if vim.bo.filetype == 'rust' then
      local task = overseer.new_task({ name = "Cargo Run", cmd = { "cargo", "run" } })
      task:start()
      overseer.run_action(task, "cargo run")
    end
  end
  local test = function()
    overseer.open({ enter = false, direction = 'bottom' })
    if vim.bo.filetype == 'rust' then
      local task = overseer.new_task({ name = "Cargo Test", cmd = { "cargo", "test" } })
      task:start()
      overseer.run_action(task, "cargo test")
    end
  end
  nnoremap('<leader>or', build_and_run, { desc = "Overseer: build and [R]un" })
  nnoremap('<leader>ot', test, { desc = "Overseer: [T]est" })
  nnoremap('<leader>oT', function() overseer.toggle({ enter = false }) end, { desc = "Overseer: [T]oggle" })
end
