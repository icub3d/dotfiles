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
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  -- Monokai theme
  use 'tanvirtin/monokai.nvim'

  -- lua line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      local colors = {
        black  = '#403E41',
        gray   = '#c1c0c0',
        white  = '#fcfcfa',
        cyan   = '#78dce8',
        green  = '#a9dc76',
        orange = '#fc9867',
        pink   = '#ff6188',
        red    = '#ff6188',
        yellow = '#ffd866',
      }

      local my_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.cyan, gui = 'bold' },
          b = { fg = colors.black, bg = colors.pink },
          c = { fg = colors.orange, bg = colors.black },
        },
        insert = { a = { fg = colors.black, bg = colors.green, gui = 'bold' } },
        visual = { a = { fg = colors.black, bg = colors.yellow, gui = 'bold' } },
        replace = { a = { fg = colors.black, bg = colors.red, gui = 'bold' } },
        inactive = {
          a = { fg = colors.pink, bg = colors.black, gui = 'bold' },
          b = { fg = colors.white, bg = colors.pink },
          c = { fg = colors.gray, bg = colors.black },
        },
      }
      require('lualine').setup({
        options = { theme = my_theme },
      })
    end,
  }

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

  -- nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require("nvim-tree").setup()
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
  use {
    'vim-test/vim-test',
    config = function()
      vim.cmd [[
         let g:test#neovim#start_normal = 1
      ]]
    end
  }

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
