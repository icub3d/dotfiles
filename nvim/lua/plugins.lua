-- install if missing
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PackerBootstrap = fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path
  })
end

-- start packer
return require('packer').startup(function(use)
  -- Monokai theme
  use 'tanvirtin/monokai.nvim'

  -- fuzzy find
  use { 'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  -- color hex codes
  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  }

  -- completion
  use {
    "hrsh7th/nvim-cmp",
    requires = {

      { "saadparwaiz1/cmp_luasnip", requires = "L3MON4D3/LuaSnip" },
      "f3fora/cmp-spell",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      { "tzachar/cmp-tabnine", run = "./install.sh" },
    },
    config = require("config.cmp"),
  }

  -- treesitter (syntax)
  use { "nvim-treesitter/nvim-treesitter", config = require("config.treesitter") }
  use {
    'lewis6991/spellsitter.nvim',
    config = function()
      require('spellsitter').setup()
    end
  }

  -- lsp
  use 'williamboman/nvim-lsp-installer'
  use { 'neovim/nvim-lspconfig', config = require('config.lsp') }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PackerBootstrap then
    require('packer').sync()
  end
end)
