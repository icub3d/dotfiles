return function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "toml", "c", "go", "lua", "rust", "css", "fish", "gomod", "javascript", "java", "json", "make",
      "proto", "typescript", "yaml" },
    sync_install = false,
    highlight = {
      enable = true,
    },
  })
end
