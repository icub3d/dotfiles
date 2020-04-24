" fish shell doesn't work well in vim? TODO
if &shell =~# 'fish$'
    set shell=sh
endif

call plug#begin(stdpath('data') . 'plugged')

Plug 'phanviet/vim-monokai-pro'
Plug 'dag/vim-Fish'

call plug#end()

" terminal colors
set termguicolors
colorscheme monokai_pro

" history
set history=1000

" show current position
set ruler

" ignore case when searching
set ignorecase

" syntax highlighting
syntax enable
filetype plugin indent on

" line numbers
set number
