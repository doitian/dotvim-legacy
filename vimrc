if v:progname =~? "evim"
  finish
endif

call pathogen#infect()
call pathogen#helptags()
set nocompatible

if has("vms")
  set nobackup
else
  set backup
endif
set history=500
set ruler
set showcmd
set incsearch
set showmatch "Show matching bracets when text indicator is over them
set ignorecase "Ignore case when searching
set smartcase

set expandtab
set shiftwidth=2
set tabstop=4
set smarttab
set backspace=indent,eol,start

syntax on
set hlsearch
filetype plugin indent on

let mapleader = ","
let g:mapleader = ","
map Q gq
inoremap <C-U> <C-G>u<C-U>

augroup vimrcEx
au!
autocmd FileType text setlocal textwidth=78
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif
augroup END

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif
