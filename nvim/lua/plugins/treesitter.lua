return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    { "nushell/tree-sitter-nu" }
  },
  config = function()
    local configs = require("nvim-treesitter.config")
    configs.setup({
      ensure_installed = { "c", "lua", "nu", "vim", "vimdoc", "markdown", "markdown_inline", "rust", "go", "tsx", "typescript" },
      sync_install = false,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            -- For example:
            -- Nushell only
            ["aP"] = "@pipeline.outer",
            ["iP"] = "@pipeline.inner",

            -- supported in other languages as well
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",
            ["aC"] = "@conditional.outer",
            ["iC"] = "@conditional.inner",
            ["iS"] = "@statement.inner",
            ["aS"] = "@statement.outer",
          },
        },
      },
    })
    -- doesn't start with nu shell scripts?
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "nu",
      callback = function(args)
        vim.treesitter.start(args.buf, "nu")
      end,
    })
  end
}
