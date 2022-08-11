-- install if missing
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  PackerBootstrap = fn.system({
    'git', 'clone', '--depth', '1',
    'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd [[packadd packer.nvim]]
end

local packer = require('packer')
packer.reset()
packer.init({
  display = {
    open_fn = function() return require('packer.util').float { border = "rounded" } end,
  }
})


-- start packer
return packer.startup(function(use)
  -- basic plugins
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'

  -- auto pairs
  use 'jiangmiao/auto-pairs'

  -- Monokai theme
  use 'tanvirtin/monokai.nvim'

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      'kyazdani42/nvim-web-devicons',
    },
  }

  -- color hex codes
  use {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  }

  -- surround
  use {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end
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
  use {
    'williamboman/mason-lspconfig.nvim',
    requires = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = require('config.lsp')
  }

  -- dap
  use {
    'rcarriga/nvim-dap-ui',
    requires = {
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', -- :TSInstall python
    },
    config = require('config.dap'),
  }

  -- testing
  use 'vim-test/vim-test'

  -- discord
  use 'andweeb/presence.nvim'

  -- go tools
  use { 'ray-x/go.nvim', config = require('config.go') }
  use 'ray-x/guihua.lua'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PackerBootstrap then
    require('packer').sync()
  end
end)
