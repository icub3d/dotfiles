return function()
  require('telescope').setup({ defaults = { file_ignore_patterns = { "node_modules", ".git/" } } })
  require('telescope').load_extension('dap')

  -- keymaps
  local builtin = require('telescope.builtin')
  local remap = require('remap')
  remap.nnoremap('<leader>fF', function() builtin.find_files({ hidden = true, no_ignore = true }) end,
    { desc = "Telescope: [F]ind [F]iles (No Ignores)" })
  remap.nnoremap('<leader>ff', builtin.find_files, { desc = "Telescope: [F]ind [F]iles" })
  remap.nnoremap('<leader>fg', builtin.live_grep, { desc = "Telescope: [F]ind [G]rep" })
  remap.nnoremap('<leader>fb', builtin.buffers, { desc = "Telescope: [F]ind [B]uffers" })
  remap.nnoremap('<leader>fh', builtin.help_tags, { desc = "Telescope: [F]ind [H]elp" })
  remap.nnoremap('<leader>fk', builtin.keymaps, { desc = "Telescope: [F]ind [K]eymaps" })
end
