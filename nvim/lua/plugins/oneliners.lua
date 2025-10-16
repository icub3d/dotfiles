return {
  {
      "kylechui/nvim-surround",
      event = "VeryLazy",
      config = function()
          require("nvim-surround").setup({})
      end
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require('colorizer').setup({})
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  }
}
