local M = {}

M.bind = function(op, outer_opts)
  outer_opts = outer_opts or { noremap = true }
  return function(lhs, rhs, opts)
    opts = vim.tbl_extend("force",
      outer_opts,
      opts or {}
    )
    vim.keymap.set(op, lhs, rhs, opts)
  end
end

M.nmap = M.bind("n", { noremap = false })
M.nnoremap = M.bind("n")
M.tnoremap = M.bind("t")
M.vnoremap = M.bind("v")
M.xnoremap = M.bind("x")
M.inoremap = M.bind("i")

return M
