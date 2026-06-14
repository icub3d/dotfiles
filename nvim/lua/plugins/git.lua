return {
  "sindrets/diffview.nvim",
  lazy = false,
  hg_config = {
    enablde = false,
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.keymap.set('n', '<leader>d', ':DiffviewOpen<cr>', { desc = 'Diffview' })

    -- Force Catppuccin Mocha background highlights for diffs
    local cp = require("catppuccin.palettes").get_palette("mocha")

    -- Helper function to blend colors with the dark base background for a subtle tint
    local function blend(color, alpha)
      return require("catppuccin.utils.colors").blend(color, cp.base, alpha)
    end

    -- VS Code-like full block backgrounds tailored for Mocha
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = blend(cp.green, 0.15), fg = "NONE" })   -- 15% Green tint
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = blend(cp.red, 0.15), fg = "NONE" })  -- 15% Red tint
    vim.api.nvim_set_hl(0, "DiffChange", { bg = blend(cp.blue, 0.15), fg = "NONE" }) -- 15% Blue tint
    vim.api.nvim_set_hl(0, "DiffText", { bg = blend(cp.blue, 0.35), fg = "NONE" })   -- 35% Blue tint for exact changed words
  end
}
