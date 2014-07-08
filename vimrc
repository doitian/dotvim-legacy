if v:progname =~? "evim"
  finish
endif

" Vundle {{{
set nocompatible
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

Bundle 'scrooloose/nerdtree'
Bundle 'vim-scripts/YankRing.vim'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'bkad/CamelCaseMotion'
Bundle 'kana/vim-textobj-user'
Bundle 'tomtom/tcomment_vim'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tsaleh/vim-matchit'
Bundle 'kchmck/vim-coffee-script'
Bundle 'rking/ag.vim'
Bundle 'kikijump/tslime.vim'
Bundle 'sickill/vim-pasta'
Bundle 'kien/ctrlp.vim'
Bundle 'slim-template/vim-slim'
Bundle 'junegunn/vim-easy-align'
Bundle 'taglist.vim'
Bundle 'Gundo'
Bundle 'bufexplorer.zip'
Bundle 'edkolev/erlang-motions.vim'
"}}}
" Theme {{{
colors solarized
set bg=dark
if has("gui_running")
  if has("mac")
    set guifont=Inconsolata\ for\ Powerline:h18
    set background=dark
  else
    set guifont=Inconsolata\ 14
    set guioptions-=m
  endif

  " Remove toolbar, left scrollbar and right scrollbar
  set guioptions-=TlLrR
  set guicursor+=a:blinkwait2000-blinkon1500 " blink slowly
  set mousehide		" Hide the mouse when typing text

  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
  let c_comment_strings=1
endif

set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

if filereadable("~/.powerline")
  python from powerline.vim import setup as powerline_setup
  python powerline_setup()
  python del powerline_setup
  let g:Powerline_colorscheme='solarized256_dark'
endif

if &t_Co > 2 || has("gui_running")
   syntax on
endif
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
" }}}
" Plugins {{{
let g:yankring_history_dir = '$HOME/.vim/.tmp'

let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")
let NERDTreeShowBookmarks=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeHighlightCursorline=1
let NERDTreeMouseMode=2
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$', '^__pycache__$' ]

let Tlist_Exit_OnlyWindow=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_WinWidth=40
let Tlist_Inc_Winwidth=1
let Tlist_Display_Prototype=1
let Tlist_Display_Tag_Scope=0
let Tlist_Use_Right_Window=1

let g:snippets_dir=expand("$HOME/.vim/snippets")

let g:ctrlp_root_markers = ['.git', '.projectile']
let g:ctrlp_map = '<leader>,'
" }}}
" Functions & Commands {{{
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction

function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - 4
    return line . ' …' . repeat(" ",fillcharcount) . foldedlinecount . ' '
endfunction

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

command! -bang -nargs=? H cd %:h
command! Sw w !sudo tee % >/dev/null
command! NT NERDTree
" }}}
" Config {{{
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=2
set shiftround
set backspace=indent,eol,start
set autoindent
set copyindent
set number
set showmatch
set ignorecase
set smartcase
set smarttab
set scrolloff=4
set virtualedit="vb"
set hlsearch
set incsearch
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·
set nolist
set pastetoggle=<F2>
set mouse=a
set fileformats="unix,dos,mac"
set formatoptions+=1

set foldcolumn=2
set foldmethod=marker
set foldlevelstart=0
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
set foldtext=MyFoldText()

set termencoding=utf-8
set encoding=utf-8
set lazyredraw
set laststatus=2
set cmdheight=2

set hidden
set switchbuf=useopen
set history=1000
set undolevels=1000
if v:version >= 730
  set undofile
  set undodir=~/.vim/.undo,~/tmp,/tmp
endif
if has("vms")
  set nobackup
else
  set backup
endif
set backupdir=~/.vim/backup
set viminfo='20,\"80
set wildmenu
set wildmode=list,full
set wildignore=*.swp,*.bak,*.pyc,*.class
set title
set visualbell
set noerrorbells
set nomodeline
set cursorline
set ruler
" }}}
" Shortcut mappings {{{
let mapleader = ","
let g:mapleader = ","
nnoremap ; :
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" insert underscore and dash
inoremap <M-u> _
inoremap <M-l> -
cnoremap <M-u> _
cnoremap <M-l> -
inoremap <M-r> <C-w>
cnoremap <M-r> <C-w>
inoremap <D-u> _
inoremap <D-l> -
cnoremap <D-u> _
cnoremap <D-l> -
inoremap <D-r> <C-w>
cnoremap <D-r> <C-w>
set t_xy=
inoremap <t_xy> <C-w>
cnoremap <t_xy> <C-w>
" save C-U in undo
inoremap <C-U> <C-G>u<C-U>

" Avoid accidental hits of <F1> while aiming for <Esc>
map! <F1> <Esc>

" Use Q for formatting the current paragraph (or visual selection)
vmap Q gq
nmap Q gqap

" make p in Visual mode replace the selected text with the yank register
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Complete whole filenames/lines with a quicker shortcut key in insert mode
imap <C-f> <C-x><C-f>
imap <C-l> <C-x><C-l>

" Quick yanking to the end of the line
nmap Y y$

cnoremap %% <C-R>=expand('%:h').'/'<cr>
vnoremap <silent> <Enter> :EasyAlign<cr>

" shortcut to jump to next conflict marker
nmap <silent> <leader>c /^\(<\\|=\\|>\)\{7\}\([^=].\+\)\?$<CR>

nnoremap <leader>; ;
nnoremap <leader>: ,
nnoremap <leader>X :nmap ,x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>

" Tame the quickfix window (open/close using ,q)
nmap <silent> <leader>q :QFix<CR>
" Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nmap <silent> <leader>d "_d
vmap <silent> <leader>d "_d

" Yank/paste to the OS clipboard with ,y and ,p
nmap <leader>y "*y
nmap <leader>Y "*yy
nmap <leader>p "*p
nmap <leader>P "*P

nmap <leader>r :YRShow<CR>

" Clears the search register
nmap <silent> <leader>/ :nohlsearch<CR>

" Folding
nnoremap <leader><Space> za
vnoremap <leader><Space> za

" Strip all trailing whitespace from a file, using ,s
nnoremap <leader>s :%s/\s\+$//<CR>:let @/=''<CR>

nnoremap <leader>a :Ag<Space>

" Reselect text that was just pasted with ,v
nnoremap <leader>v V`]

" Gundo.vim
nnoremap <leader>u :GundoToggle<CR>

" Bind tslime again
vnoremap <leader>t "ry :call Send_to_Tmux(@r)<cr>
nmap <leader>t vip<leader>t

" Find file here
nmap <leader>h :e %%

nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>N :NERDTreeFind<CR>

nmap <leader>l :TlistToggle<CR>

map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
" }}}
" Filetype specific handling {{{
filetype indent plugin on
augroup invisible_chars "{{{
  au!

  " Show invisible characters in all of these files
  autocmd filetype vim setlocal list
  autocmd filetype ruby setlocal list
  autocmd filetype javascript,css setlocal list
augroup end "}}}

augroup yaml_header_matters "{{{
  au!

  autocmd filetype markdown syntax region frontmatter start=/\%^---$/ end=/^---$/
  autocmd filetype markdown highlight link frontmatter Comment
augroup end "}}}

augroup restore_position "{{{
  au!
  autocmd FileType text setlocal textwidth=78
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END "}}}

augroup javascript_ft "{{{
  au!

  autocmd BufNewFile,BufRead *.json set ft=javascript
augroup END "}}}
" }}}
