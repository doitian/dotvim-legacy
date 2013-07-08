if v:progname =~? "evim"
  finish
endif

set nocompatible
call pathogen#infect()

let mapleader = ","
let g:mapleader = ","

" Theme {{{

" set statusline=%<%f%{fugitive#statusline()}\ %h%m%r%=%-14.(%l,%c%V%)\ %P

if has("gui_running")
  if has("mac")
    set guifont=Inconsolata:h18
    set background=dark
  else
    set guifont=Inconsolata\ 14
    set guioptions-=m
  endif

  colors solarized

  " Remove toolbar, left scrollbar and right scrollbar
  set guioptions-=T
  set guioptions-=l
  set guioptions-=L
  set guioptions-=r
  set guioptions-=R

  set guicursor+=a:blinkwait2000-blinkon1500 " blink slowly
  set mousehide		" Hide the mouse when typing text
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
  let c_comment_strings=1

  highlight Normal guibg=grey90
  highlight Cursor guibg=Green guifg=NONE
  highlight lCursor guibg=Cyan guifg=NONE
  highlight NonText guibg=grey80
  highlight Constant gui=NONE guibg=grey95
  highlight Special gui=NONE guibg=grey95

  " Screen recording mode
  function! ScreenRecordMode()
    set columns=86
    set guifont=Inconsolata:h14
    set cmdheight=1
    "colorscheme molokai_deep
  endfunction
  command! -bang -nargs=0 ScreenRecordMode call ScreenRecordMode()
else
  set bg=dark
  colors solarized
endif

python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
let g:Powerline_colorscheme='solarized256_dark'
" }}}

" Editing behaviour {{{
set showmode                    " always show what mode we're currently editing in
set nowrap                      " don't wrap lines
set tabstop=4                   " a tab is four spaces
set softtabstop=4               " when hitting <BS>, pretend like a tab is removed, even if spaces
set expandtab                   " expand tabs by default (overloadable per file type later)
set shiftwidth=2                " number of spaces to use for autoindenting
set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set autoindent                  " always set autoindenting on
set copyindent                  " copy the previous indentation on autoindenting
set number                      " always show line numbers
set showmatch                   " set show matching parenthesis
set ignorecase                  " ignore case when searching
set smartcase                   " ignore case if search pattern is all lowercase,
                                "    case-sensitive otherwise
set smarttab                    " insert tabs on the start of a line according to
                                "    shiftwidth, not tabstop
set scrolloff=4                 " keep 4 lines off the edges of the screen when scrolling
set virtualedit="vb"
set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type
set gdefault                    " search/replace "globally" (on a line) by default
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·

set nolist                      " don't show invisible characters by default,
                                " but it is enabled for some file types (see later)
set pastetoggle=<F2>            " when in insert mode, press <F2> to go to
                                "    paste mode, where you can paste mass data
                                "    that won't be autoindented
set mouse=a                     " enable using the mouse if terminal emulator
                                "    supports it (xterm does)
set fileformats="unix,dos,mac"
set formatoptions+=1            " When wrapping paragraphs, don't end lines
                                "    with 1-letter words (looks stupid)

" Thanks to Steve Losh for this liberating tip
" See http://stevelosh.com/blog/2010/09/coming-home-to-vim
nnoremap / /\v
vnoremap / /\v

" Speed up scrolling of the viewport slightly
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
" }}}

" Folding rules {{{
set foldenable                  " enable folding
set foldcolumn=2                " add a fold column
set foldmethod=marker           " detect triple-{ style fold markers
set foldlevelstart=0            " start out with everything folded
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
                                " which commands trigger auto-unfold
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
set foldtext=MyFoldText()
" }}}

" Editor layout {{{
set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " don't update the display while executing macros
set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window
set cmdheight=2                 " use a status bar that is 2 rows high
" }}}

" Vim behaviour {{{
set hidden                      " hide buffers instead of closing them this
                                "    means that the current buffer can be put
                                "    to background without being written; and
                                "    that marks and undo history are preserved
set switchbuf=useopen           " reveal already opened files from the
                                " quickfix window instead of opening new
                                " buffers
set history=1000                " remember more commands and search history
set undolevels=1000             " use many muchos levels of undo
if v:version >= 730
    set undofile                " keep a persistent backup file
    set undodir=~/.vim/.undo,~/tmp,/tmp
endif
if has("vms")
  set nobackup
else
  set backup
endif
set backupdir=~/.vim/backup
"set nobackup                    " do not keep backup files, it's 70's style cluttering
"set noswapfile                  " do not write annoying intermediate swap files,
                                "    who did ever restore from swap files anyway?
"set directory=~/.vim/.tmp,~/tmp,/tmp
                                " store swap files in one of these directories
                                "    (in case swapfile is ever turned on)
set viminfo='20,\"80            " read/write a .viminfo file, don't store more
                                "    than 80 lines of registers
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list,full          " show a list when pressing tab and complete
                                "    first full match
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                       " change the terminal's title
set visualbell                  " don't beep
set noerrorbells                " don't beep
set showcmd                     " show (partial) command in the last line of the screen
                                "    this also shows visual selection info
set nomodeline                  " disable mode lines (security measure)
"set ttyfast                     " always use a fast terminal
set cursorline                  " underline the current line, for quick orientation
set ruler                       " show row,column info in modeline

" Tame the quickfix window (open/close using ,q)
nmap <silent> <leader>q :QFix<CR>

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
" }}}

" Highlighting {{{
if &t_Co > 2 || has("gui_running")
   syntax on
endif
" }}}

" Conflict markers {{{
" highlight conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" shortcut to jump to next conflict marker
nmap <silent> <leader>c /^\(<\\|=\\|>\)\{7\}\([^=].\+\)\?$<CR>

" }}}

" Shortcut mappings {{{

nnoremap ; :
nnoremap <leader>X :nmap ,x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>

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

" Shortcut to make
nmap mk :make<CR>

" Swap implementations of ` and ' jump to markers
" By default, ' jumps to the marked line, ` jumps to the marked line and
" column, so swap them
nnoremap ' `
nnoremap ` '

" Use the damn hjkl keys
" map <up> <nop>
" map <down> <nop>
" map <left> <nop>
" map <right> <nop>
" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap j gj
nnoremap k gk

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Complete whole filenames/lines with a quicker shortcut key in insert mode
imap <C-f> <C-x><C-f>
imap <C-l> <C-x><C-l>

" Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nmap <silent> <leader>d "_d
vmap <silent> <leader>d "_d

" Quick yanking to the end of the line
nmap Y y$

" Yank/paste to the OS clipboard with ,y and ,p
nmap <leader>y "+y
nmap <leader>Y "+yy
nmap <leader>p "+p
nmap <leader>P "+P

" YankRing stuff
let g:yankring_history_dir = '$HOME/.vim/.tmp'
nmap <leader>r :YRShow<CR>

" Clears the search register
nmap <silent> <leader>/ :nohlsearch<CR>

" Pull word under cursor into LHS of a substitute (for quick search and
" replace)
nmap <leader>z :%s#\<<C-r>=expand("<cword>")<CR>\>#

" Keep search matches in the middle of the window and pulse the line when moving
" to them.
nnoremap n n:call PulseCursorLine()<cr>
nnoremap N N:call PulseCursorLine()<cr>

" Sudo to write
command! Sw w !sudo tee % >/dev/null

" Folding
nnoremap <leader><Space> za
vnoremap <leader><Space> za

" Strip all trailing whitespace from a file, using ,s
nnoremap <leader>s :%s/\s\+$//<CR>:let @/=''<CR>

" Run Ack fast
let g:ackprg = 'ag --nogroup --nocolor --column'
nnoremap <leader>a :Ack<Space>

" Reselect text that was just pasted with ,v
nnoremap <leader>v V`]

" Gundo.vim
nnoremap <leader>u :GundoToggle<CR>

" Bind tslime again
vnoremap <leader>t "ry :call Send_to_Tmux(@r)<cr>
nmap <leader>t vip<leader>t

" Find file here

cnoremap %% <C-R>=expand('%:h').'/'<cr>
nmap <leader>h :e %%
" CD HERE
command! -bang -nargs=? H cd %:h

" }}}

" NERDTree settings {{{
" Put focus to the NERD Tree with F3 (tricked by quickly closing it and
" immediately showing it again, since there is no :NERDTreeFocus command)
nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>N :NERDTreeFind<CR>
command NT NERDTree

" Store the bookmarks file
let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")

" Show the bookmarks table on startup
let NERDTreeShowBookmarks=1

" Show hidden files, too
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1

" Quit on opening files from the tree
let NERDTreeQuitOnOpen=1

" Highlight the selected entry in the tree
let NERDTreeHighlightCursorline=1

" Use a single click to fold/unfold directories and a double click to open
" files
let NERDTreeMouseMode=2

" Don't display these kinds of files
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$', '^__pycache__$' ]

" }}}

" TagList settings {{{
nmap <leader>l :TlistToggle<CR>

" quit Vim when the TagList window is the last open window
let Tlist_Exit_OnlyWindow=1         " quit when TagList is the last open window
let Tlist_GainFocus_On_ToggleOpen=1 " put focus on the TagList window when it opens
"let Tlist_Process_File_Always=1     " process files in the background, even when the TagList window isn't open
"let Tlist_Show_One_File=1           " only show tags from the current buffer, not all open buffers
let Tlist_WinWidth=40               " set the width
let Tlist_Inc_Winwidth=1            " increase window by 1 when growing

" shorten the time it takes to highlight the current tag (default is 4 secs)
" note that this setting influences Vim's behaviour when saving swap files,
" but we have already turned off swap files (earlier)
"set updatetime=1000

" show function/method prototypes in the list
let Tlist_Display_Prototype=1

" don't show scope info
let Tlist_Display_Tag_Scope=0

" show TagList window on the right
let Tlist_Use_Right_Window=1

" }}}

" Plugins {{{
let g:snippets_dir=expand("$HOME/.vim/snippets")
let g:ctrlp_root_markers = ['.eproject']
let g:ctrlp_map = '<leader>,'

nnoremap <leader>gd :Gdiff!<Enter>
nnoremap <leader>gs :Gstatus<Enter>
nnoremap <leader>gl :Glog<Enter>
nnoremap <leader>ga :Git add %<CR><CR>
nnoremap <leader>gc :Gcommit<Enter>
nnoremap <leader>gC :Gcommit -v<Enter>

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

" Commands {{{
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif
" }}}

" Pulse ------------------------------------------------------------------- {{{

function! PulseCursorLine()
    let current_window = winnr()

    windo set nocursorline
    execute current_window . 'wincmd w'

    setlocal cursorline

    redir => old_hi
        silent execute 'hi CursorLine'
    redir END
    let old_hi = split(old_hi, '\n')[0]
    let old_hi = substitute(old_hi, 'xxx', '', '')

    hi CursorLine guibg=#2a2a2a
    redraw
    sleep 5m

    hi CursorLine guibg=#3a3a3a
    redraw
    sleep 5m

    hi CursorLine guibg=#4a4a4a
    redraw
    sleep 5m

    hi CursorLine guibg=#3a3a3a
    redraw
    sleep 5m

    hi CursorLine guibg=#2a2a2a
    redraw
    sleep 5m

    execute 'hi ' . old_hi

    windo set cursorline
    execute current_window . 'wincmd w'
endfunction

" }}}

