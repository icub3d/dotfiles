vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%{v:lnum} %{v:relnum}'
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.compatible = false
vim.opt.showmatch = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wildmode = 'longest,list'
vim.opt.mouse = 'a'
vim.opt.completeopt = 'menu,menuone,noselect,popup'
vim.opt.shortmess:append("c")
vim.opt.ttyfast = true
vim.opt.spell = true
vim.opt.spelllang = "en"
vim.opt.spellsuggest = "best,9"
vim.opt.spelloptions = "camel"
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.signcolumn = 'number'
vim.opt.winborder = 'rounded'

-- use nushell
vim.opt.sh = "nu"
vim.opt.shelltemp = false
vim.opt.shellredir = "out+err> %s"
vim.opt.shellcmdflag = "--stdin --no-newline -c"
vim.opt.shellxescape = ""
vim.opt.shellxquote = ""
vim.opt.shellquote = ""
vim.opt.shellpipe =
'| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record'

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.load_perl_provider = 0
vim.g.load_ruby_provider = 0
