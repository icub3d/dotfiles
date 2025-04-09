local opts = {
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  ignorecase = true,
  smartcase = true,
  hlsearch = false,
  backup = false,
  writebackup = false,
  compatible = false,
  showmatch = true,
  number = true,
  expandtab = true,
  autoindent = true,
  smartindent = true,
  wildmode = 'longest,list',
  mouse = 'a',
  completeopt = 'menu,menuone,noselect',
  ttyfast = true,
  spell = true,
  spelllang = "en",
  spellsuggest = "best,9",
  spelloptions = "camel",
  swapfile = false,
  termguicolors = true,
  signcolumn = 'number',
  clipboard = 'unnamedplus',
}

for k, v in pairs(opts) do
  if v == true then
    vim.api.nvim_command('set ' .. k)
  elseif v == false then
    vim.api.nvim_command('set no' .. k)
  else
    vim.api.nvim_command('set ' .. k .. '=' .. v)
  end
end

local globals = {
  ["mapleader"] = ' ',
  ["maplocalleader"] = ' ',
  ["load_perl_provider"] = 0,
  ["load_ruby_provider"] = 0,
}

for k, v in pairs(globals) do
  vim.g[k] = v
end
