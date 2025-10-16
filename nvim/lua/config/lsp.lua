local builtin = require('telescope.builtin')

vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP: [D]efinition" })
vim.keymap.set("n", '<leader>lD', vim.lsp.buf.declaration, { desc = "LSP: [D]eclaration" })
vim.keymap.set("n", '<leader>lh', vim.lsp.buf.hover, { desc = "LSP: [H]over" })
vim.keymap.set("n", '<leader>lr', builtin.lsp_references, { desc = "LSP: [R]eferences" })
vim.keymap.set("n", '<leader>lE', vim.lsp.buf.references, { desc = "LSP: [R]eferences" })
vim.keymap.set("n", '<leader>li', vim.lsp.buf.implementation, { desc = "LSP: [I]mplementation" })
vim.keymap.set("n", '<leader>ls', builtin.lsp_document_symbols, { desc = "LSP: [D]ocument Symbols" })
vim.keymap.set("n", '<leader>lt', vim.lsp.buf.type_definition, { desc = "LSP: [T]ype Definition" })
vim.keymap.set("n", '<leader>lR', vim.lsp.buf.rename, { desc = "LSP: [R]ename symbol" })
vim.keymap.set("n", '<leader>la', vim.lsp.buf.code_action, { desc = "LSP: Code [A]ction" })
vim.keymap.set("n", '<leader>l]', function() vim.diagnostic.jump({ count = 1, float = true, wrap = true }) end,
  { desc = "LSP: next diagnostic" })
vim.keymap.set("n", '<leader>l[', function() vim.diagnostic.jump({ count = -1, float = true, wrap = true }) end,
  { desc = "LSP: prev diagnostic" })
vim.keymap.set("n", '<leader>l{', function() vim.diagnostic.jump({ count = -10000000, float = true, wrap = false }) end,
  { desc = "LSP: first diagnostic" })
vim.keymap.set("n", '<leader>l}', function() vim.diagnostic.jump({ count = 10000000, float = true, wrap = false }) end,
  { desc = "LSP: last diagnostic" })
vim.keymap.set("n", '<leader>le', vim.diagnostic.open_float, { desc = "LSP: Diagnostic op[e]n float" })
vim.keymap.set("n", '<leader>lQ', vim.diagnostic.setloclist, { desc = "LSP: Setloclist" })
vim.keymap.set("n", '<leader>lw', vim.lsp.buf.add_workspace_folder, { desc = "LSP: [W]orkspace Add" })
vim.keymap.set("n", '<leader>lW', vim.lsp.buf.remove_workspace_folder, { desc = "LSP: [W]orkspace Remove" })
vim.keymap.set("n", '<leader>lf', vim.lsp.buf.format, { desc = "LSP: [F]ormat" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Only set up format on save if the client supports formatting
    if client and client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
