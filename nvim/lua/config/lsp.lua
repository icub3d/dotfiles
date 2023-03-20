return function()
  local remap = require('remap')
  local nnoremap = remap.nnoremap

  require("mason").setup {
    automatic_installation = true,
  }

  require("mason-lspconfig").setup {
    automatic_installation = true,
    ensure_installed = {
      "lua_ls",
      "emmet_ls",
      "clangd",
      "tsserver",
      "pyright",
      "rust_analyzer",
      "gopls",
      "tailwindcss",
      "cssls",
      "html",
      "solargraph",
    }
  }

  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  nnoremap('<leader>le', vim.diagnostic.open_float)
  nnoremap('[d', vim.diagnostic.goto_prev)
  nnoremap(']d', vim.diagnostic.goto_next)
  nnoremap('<leader>q', vim.diagnostic.setloclist)


  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- context line
    local navic = require("nvim-navic")
    navic.attach(client, bufnr)

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, buffer = bufnr }
    local bufremap = remap.bind('n', bufopts)
    bufremap('gD', vim.lsp.buf.declaration)
    bufremap('gd', vim.lsp.buf.definition)
    bufremap('K', vim.lsp.buf.hover)
    bufremap('gi', vim.lsp.buf.implementation)
    bufremap('<C-k>', vim.lsp.buf.signature_help)
    bufremap('<leader>wa', vim.lsp.buf.add_workspace_folder)
    bufremap('<leader>wr', vim.lsp.buf.remove_workspace_folder)
    bufremap('<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
    bufremap('<leader>D', vim.lsp.buf.type_definition)
    bufremap('<leader>rn', vim.lsp.buf.rename)
    bufremap('<leader>ca', vim.lsp.buf.code_action)
    bufremap('gr', vim.lsp.buf.references)
    bufremap('<leader>f', vim.lsp.buf.formatting)
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
  lspconfig.solargraph.setup(default)

  -- format on save
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    command = "lua vim.lsp.buf.formatting_sync()",
  })
end
