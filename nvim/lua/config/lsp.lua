return function()
  -- We don't need any of this unless we the word 'dev' is in our `.selected_packages` file.
  local selected_packages = vim.fn.readfile(vim.fn.expand('~/dev/dotfiles/.selected_packages'))
  selected_packages = table.concat(selected_packages, ' ')
  if not string.find(selected_packages, 'dev') then
    return
  end

  local builtin = require('telescope.builtin')
  local remap = require('remap')
  remap.nnoremap('<leader>ld', vim.lsp.buf.definition, { desc = "LSP: [D]efinition" })
  remap.nnoremap('<leader>lD', vim.lsp.buf.declaration, { desc = "LSP: [D]eclaration" })
  remap.nnoremap('<leader>lh', vim.lsp.buf.hover, { desc = "LSP: [H]over" })
  remap.nnoremap('<leader>lr', builtin.lsp_references, { desc = "LSP: [R]eferences" })
  remap.nnoremap('<leader>lE', vim.lsp.buf.references, { desc = "LSP: [R]eferences" })
  remap.nnoremap('<leader>li', vim.lsp.buf.implementation, { desc = "LSP: [I]mplementation" })
  remap.nnoremap('<leader>ls', builtin.lsp_document_symbols, { desc = "LSP: [D]ocument Symbols" })
  remap.nnoremap('<leader>lt', vim.lsp.buf.type_definition, { desc = "LSP: [T]ype Definition" })
  remap.nnoremap('<leader>lR', vim.lsp.buf.rename, { desc = "LSP: [R]ename symbol" })
  remap.nnoremap('<leader>la', vim.lsp.buf.code_action, { desc = "LSP: Code [A]ction" })
  remap.nnoremap('<leader>l[', vim.diagnostic.goto_prev, { desc = "LSP: next diagnostic" })
  remap.nnoremap('<leader>l]', vim.diagnostic.goto_next, { desc = "LSP: prev diagnostic" })
  remap.nnoremap('<leader>le', vim.diagnostic.open_float, { desc = "LSP: Diagnostic op[e]n float" })
  remap.nnoremap('<leader>lQ', vim.diagnostic.setloclist, { desc = "LSP: Setloclist" })
  remap.nnoremap('<leader>lw', vim.lsp.buf.add_workspace_folder, { desc = "LSP: [W]orkspace Add" })
  remap.nnoremap('<leader>lW', vim.lsp.buf.remove_workspace_folder, { desc = "LSP: [W]orkspace Remove" })
  remap.nnoremap('<leader>lf', vim.lsp.buf.format, { desc = "LSP: [F]ormat" })

  require("mason").setup {
    automatic_installation = true,
  }

  require("mason-lspconfig").setup {
    automatic_installation = true,
    ensure_installed = {
      "clangd",
      "cssls",
      "emmet_ls",
      "gopls",
      "html",
      "lua_ls",
      "pyright",
      "rust_analyzer",
      "tailwindcss",
      "tsserver",
    }
  }

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    require("lsp-format").on_attach(client, bufnr)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- context line
    local navic = require("nvim-navic")
    navic.attach(client, bufnr)
  end

  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
  local default = {
    capabilities = capabilities,
    on_attach = on_attach,
  }
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  }
  lspconfig.emmet_ls.setup {
    capabilities = capabilities,
    filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
  }
  lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      ['rust-analyzer'] = {
        -- procMacro = {
        --   ignored = {
        --     leptos_macro = {
        --       "server",
        --     },
        --   },
        -- },
        checkOnSave = {
          allFeatures = true,
          overrideCommand = {
            'cargo', 'clippy', '--workspace', '--message-format=json',
            '--all-targets', '--all-features'
          }
        }
      }
    }
  })
  lspconfig.clangd.setup(default)
  lspconfig.tsserver.setup(default)
  lspconfig.pyright.setup(default)
  lspconfig.gopls.setup(default)
  lspconfig.jdtls.setup(default)
  lspconfig.cssls.setup(default)
  lspconfig.html.setup(default)
  lspconfig.nushell.setup(default)
end
