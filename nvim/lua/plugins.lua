-- install lazy.
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

  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          insert_only = false,
        }
      })
    end,
  },

  {
    'LhKipp/nvim-nu',
    build = ":TSInstall nu"
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
    lazy = false,
    config = require('config.telescope'),
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'folke/neodev.nvim',
      'hrsh7th/nvim-cmp',
      'lukas-reineke/lsp-format.nvim',
    },
    config = require('config.lsp'),
  },

  -- copilot
  { 'github/copilot.vim' },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    keys = {
      { '<leader>cc', ':CopilotChatOpen<CR>', mode = 'n', noremap = true, desc = "[C]opilot [C]hat Open" },
      { '<leader>cc', ':CopilotChatOpen<CR>', mode = 'v', noremap = true, desc = "[C]opilot [C]hat Open" },
    },
  },

  -- comment
  {
    'numToStr/Comment.nvim',
    config = true,
    opts = {},
    lazy = false,
  },

  -- auto pairs
  {
    "windwp/nvim-autopairs",
    config = true,
  },

  -- colorscheme: catppucin
  {
    "catppuccin/nvim",
    name = "catppucin",
    priority = 1000,
    lazy = false,
    init = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- lua line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
      'SmiteshP/nvim-navic',
      'neovim/nvim-lspconfig',
    },
    config = function()
      local navic = require('nvim-navic')
      require('lualine').setup({
        options = { theme = 'catppuccin' },
        extensions = { 'nvim-tree' },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'lsp_progress' },
          lualine_x = {},
          lualine_y = { 'encoding', 'fileformat', 'filetype' },
          lualine_z = { 'progress', 'location' },
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

  -- auto complete
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
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
      { '<leader>ft', ':NvimTreeToggle<cr>', mode = 'n', noremap = true, desc = "[F]ile Project [T]ree" },
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
    },
    config = require("config.cmp"),
  },

  -- treesitter (syntax)
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nushell/tree-sitter-nu",
    },
    config = require("config.treesitter"),
    build = ":TSUpdate",
  },

  -- discord
  'andweeb/presence.nvim',

  -- go tools
  {
    'ray-x/go.nvim',
    config = function() require('go').setup({}) end,
    keys = {
      { '<leader>cr', ":GoCoverage<CR>",    mode = 'n', noremap = true, desc = "[G]o [C]overage" },
      { '<leader>ct', ":GoCoverage -t<CR>", mode = 'n', noremap = true, desc = "[G]o -[t] Coverage" },
      { '<leader>r',  ":GoRun<CR>",         mode = 'n', noremap = true, desc = "[G]o [R]un" },
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
      { '<leader>tt', ":TestNearest -strategy=neovim<cr>", mode = 'n', noremap = true, desc = "[T]est nearest [T]est" },
      { '<leader>tf', ":TestFile -strategy=neovim<cr>",    mode = 'n', noremap = true, desc = "[T]est [F]ile" },
      { '<leader>ts', ":TestSuite -strategy=neovim<cr>",   mode = 'n', noremap = true, desc = "[T]est [S]uite" },
      { '<leader>tl', ":TestLast -strategy=neovim<cr>",    mode = 'n', noremap = true, desc = "[T]est [L]ast" },
      { '<leader>tv', ":TestVisit -strategy=neovim<cr>",   mode = 'n', noremap = true, desc = "[T]est [V]isit" },
    },
  },

  -- null-ls
  {
    'jose-elias-alvarez/null-ls.nvim',
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.black,
        }
      })
    end
  },

  -- dap
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', -- :TSInstall python
      'nvim-neotest/nvim-nio',
      'leoluz/nvim-dap-go',
    },
    config = require('config.dap'),
  },

  -- neoterm
  {
    "kassio/neoterm",
    config = function()
      vim.g.neoterm_size = tostring(0.3 * vim.o.columns)
      vim.g.neoterm_autoinsert = true
      vim.g.neoterm_default_mod = "botright vertical"
    end,
  },

  -- task runner
  {
    "stevearc/overseer.nvim",
    opts = {
      task_list = {
        direction = "bottom",
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
    config = require("config.overseer"),
  },

  -- gen
  {
    "David-Kunz/gen.nvim",
    opts = {
      model = "llama3",
    },
    keys = {
      { '<leader>gg', ':Gen<CR>', mode = 'n', noremap = true, desc = "[G]en Model" },
      { '<leader>gg', ':Gen<CR>', mode = 'v', noremap = true, desc = "[G]en Model" },
    },
  },

  -- peek
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
}

require("lazy").setup(plugins)
