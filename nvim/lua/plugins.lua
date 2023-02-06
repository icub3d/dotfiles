local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local plugins = {
  -- basic plugins
  'nvim-lua/popup.nvim',
  'nvim-lua/plenary.nvim',

  -- auto pairs
  {
    "windwp/nvim-autopairs",
    config = true,
  },

  -- context line
  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
  },

  -- lua line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
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
      local navic = require('nvim-navic')
      require('lualine').setup({
        options = { theme = my_theme },
        extensions = { 'nvim-tree' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {
          lualine_a = {},
          lualine_b = { { 'filename', path = 1 } },
          lualine_c = { { navic.get_location, cond = navic.is_available } },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {}
        }
      })
    end,
  },


  -- monokai theme
  {
    'tanvirtin/monokai.nvim',
    lazy = false,
    priotiy = 1000,
    init = function()
      local monokai = require('monokai')
      monokai.setup {
        palette = {
          base0 = '#222426',
          base1 = '#211F22',
          base2 = '#2d2a2e',
          base3 = '#5b595c',
          base4 = '#333842',
          base5 = '#4d5154',
          base6 = '#72696A',
          base7 = '#fcfcfa',
          base8 = '#e3e3e1',
          border = '#A1B5B1',
          brown = '#504945',
          white = '#FFF1F3',
          grey = '#72696A',
          black = '#000000',
          pink = '#FF6188',
          green = '#A9DC76',
          aqua = '#78DCE8',
          yellow = '#FFD866',
          orange = '#FC9867',
          purple = '#AB9DF2',
          red = '#ff6188',
          diff_add = '#3d5213',
          diff_remove = '#4a0f23',
          diff_change = '#27406b',
          diff_text = '#23324d',
        }
      }
    end
  },

  -- telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-dap.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require('telescope').setup({ defaults = { file_ignore_patterns = { "node_modules", ".git" } } })
      require('telescope').load_extension('dap')
    end,
    keys = {
      { '<leader>ff', "<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>", mode = 'n', noremap = true },
      { '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", mode = 'n', noremap = true },
      { '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", mode = 'n', noremap = true },
      { '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", mode = 'n', noremap = true },
      { '<leader>fk', ":Telescope keymaps<cr>", mode = 'n', noremap = true },
    },
  },

  -- color hex codes
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require('colorizer').setup()
    end,
  },

  -- surround
  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- nvim-tree
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      require("nvim-tree").setup({ filters = { custom = { "^.git$" } } })
    end,
    keys = {
      { '<leader>dt', ':NvimTreeToggle<cr>', mode = 'n', noremap = true },
    },
  },

  -- completion
  "L3MON4D3/LuaSnip",
  {
    "hrsh7th/nvim-cmp",
    depdenencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "f3fora/cmp-spell",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      { "tzachar/cmp-tabnine", build = "./install.sh" },
    },
    config = require("config.cmp"),
  },

  -- treesitter (syntax)
  { "nvim-treesitter/nvim-treesitter", config = require("config.treesitter") },
  {
    'lewis6991/spellsitter.nvim',
    config = function()
      require('spellsitter').setup()
    end
  },

  -- discord
  'andweeb/presence.nvim',

  -- go tools
  {
    'ray-x/go.nvim',
    config = function() require('go').setup() end,
    keys = {
      { '<leader>cr', ":GoCoverage<CR>", mode = 'n', noremap = true },
      { '<leader>ct', ":GoCoverage -t<CR>", mode = 'n', noremap = true },
      { '<leader>r', ":GoRun<CR>", mode = 'n', noremap = true },
      { '<leader>ta', ":GoTest<CR>", mode = 'n', noremap = true },
      { '<leader>tf', ":GoTestFile<CR>", mode = 'n', noremap = true },
      { '<leader>tu', ":GoTestFunc<CR>", mode = 'n', noremap = true },
      { '<leader>tp', ":GoTestPkg<CR>", mode = 'n', noremap = true },
    }
  },
  'ray-x/guihua.lua',

  -- testing
  {
    'vim-test/vim-test',
    config = function()
      vim.cmd [[
         let g:test#neovim#start_normal = 1
      ]]
    end,
    keys = {
      { '<leader>tt', ":TestNearest -strategy=neovim<cr>", mode = 'n', noremap = true },
      { '<leader>tf', ":TestFile -strategy=neovim<cr>", mode = 'n', noremap = true },
      { '<leader>ts', ":TestSuite -strategy=neovim<cr>", mode = 'n', noremap = true },
      { '<leader>tl', ":TestLast -strategy=neovim<cr>", mode = 'n', noremap = true },
      { '<leader>tv', ":TestVisit -strategy=neovim<cr>", mode = 'n', noremap = true },
    },
  },

  -- lsp
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = require('config.lsp')
  },

  -- dap
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', -- :TSInstall python
      'leoluz/nvim-dap-go',
    },
    config = require('config.dap'),
  },
}

require("lazy").setup(plugins)
