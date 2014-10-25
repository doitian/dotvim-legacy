if v:progname =~? "evim"
  finish
endif
set nocompatible

"{{{ Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Plugin 'gmarik/vundle'

Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'bkad/CamelCaseMotion'
Plugin 'kana/vim-textobj-user'
Plugin 'kana/vim-textobj-indent'
Plugin 'tomtom/tcomment_vim'
Plugin 'vim-ruby/vim-ruby'
Plugin 'kchmck/vim-coffee-script'
Plugin 'rking/ag.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'slim-template/vim-slim'
Plugin 'junegunn/vim-easy-align'
Plugin 'taglist.vim'
Plugin 'Gundo'
Plugin 'bufexplorer.zip'
Plugin 'edkolev/erlang-motions.vim'
Plugin 'elixir-lang/vim-elixir'
Plugin 'scrooloose/syntastic'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'amiorin/ctrlp-z'
Plugin 'thinca/vim-visualstar'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tommcdo/vim-exchange'
Plugin 'bling/vim-airline'
" Plugin 'SirVer/ultisnips'
" Plugin 'honza/vim-snippets
"}}}

"{{{ Theme
colors solarized
set bg=dark
if has("gui_running")
  if has("mac")
    set guifont=Source\ Code\ Pro\ Medium:h16
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

set noshowmode
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l
if has("mac")
  let g:airline_powerline_fonts = 1
endif

if &t_Co > 2 || has("gui_running")
  syntax on
endif
hi MatchParen cterm=bold ctermbg=none ctermfg=red gui=bold guibg=NONE guifg=red
"}}}

"{{{ Plugins Options
let NERDTreeBookmarksFile=expand("$HOME/.vim/NERDTreeBookmarks")
let NERDTreeShowBookmarks=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1
let NERDTreeHighlightCursorline=1
let NERDTreeMouseMode=2
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$', '^__pycache__$',
            \ '\.sublime-project$', '\.sublime-workspace$']


let Tlist_Exit_OnlyWindow=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_WinWidth=40
let Tlist_Inc_Winwidth=1
let Tlist_Display_Prototype=1
let Tlist_Display_Tag_Scope=0
let Tlist_Use_Right_Window=1

let g:ctrlp_root_markers = ['.git', '.svn', '.projectile']
let g:ctrlp_map = '<leader>,'
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'cd %s && git ls-files -co --exclude-standard'],
    \ 2: ['.svn', 'cd %s && svn list -R . | grep -v "/$"'],
    \ },
  \ 'fallback': 'ag %s -l --nocolor -g ""'
  \ }
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|_build)$',
  \ }
let g:ctrlp_z_nerdtree = 1
let g:ctrlp_extensions = ['Z', 'F']

" syntastic
let g:syntastic_mode_map = { "mode": "passive",
                           \ "active_filetypes": [],
                           \ "passive_filetypes": [] }
let g:syntastic_auto_loc_list = 1
"}}}

"{{{ Functions & Commands
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

command! -bang -nargs=? SyntasticNext call SyntasticNext(<bang>0)
function! SyntasticNext(forced)
  if g:SyntasticLoclist.current().isEmpty() || a:forced != 0
    write
    SyntasticCheck
    Errors
    if !g:SyntasticLoclist.current().isEmpty()
      lopen 10
      ll
    endif
  else
    lnext
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

command! Sw w !sudo tee % >/dev/null
command! NT NERDTree

let s:tmux_last_command=""
let s:tmux_last_no_new_line=1
function! TmuxSend(text, no_new_line)
  if !exists("s:tmux_args")
    let s:tmux_args = input("TmuxArgs ", "-t ")
  end

  if a:no_new_line
    let l:newline = ""
  else
    let l:newline = " C-j"
  end
  let s:tmux_last_command = a:text
  let s:tmux_last_no_new_line = a:no_new_line
  " echo "tmux send-keys " . s:tmux_args . " " . shellescape(a:text) . l:newline
  call system("tmux send-keys " . s:tmux_args . " " . shellescape(a:text) . l:newline)
endfunction

function! TmuxRepeat()
  call TmuxSend(s:tmux_last_command, s:tmux_last_no_new_line)
endfunction

command! -bang -nargs=1 TmuxArgs let s:tmux_args=<q-args>
command! -bang -nargs=1 TmuxSend :call TmuxSend(<q-args>, <bang>0)
command! -bang TmuxRepat :call TmuxRepat()
command! -bang -nargs=1 TmuxSetBuffer :call system("tmux set-buffer " . shellescape(<q-args>))

command! Reload :source ~/.vimrc | :filetype detect
command! Clear :bufdo bd | :silent! argd *
command! -nargs=1 -complete=dir Cd :bufdo bd | :silent! argd * | cd <q-args>

" Toggle [ ] and [x]
function! ToggleTodoStatus(clear)
  if a:clear
    s/\[[-x]\]/[ ]/e
  else
    s/\[\([- x]\)\]/\=submatch(1) == ' ' ? '[x]' : '[ ]'/e
  endif
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction
"}}}

"{{{ Config
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=2
set shiftround
set backspace=indent,eol,start
set autoindent
set copyindent
set number
"set showmatch
set ignorecase
set smartcase
set smarttab
set scrolloff=4
set virtualedit="vb"
set hlsearch
set incsearch
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·
set nolist
set pastetoggle=<F12>
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
set backupdir=~/.vim/backup//
set viminfo='20,\"80
set wildmenu
set wildmode=list,full
set wildignore=*.swp,*.bak,*.pyc,*.class,*.beam
set title
set visualbell
set noerrorbells
set nomodeline
set cursorline
set ruler

set spellfile=$HOME/.vim-spell-en.utf-8.add
set spelllang=en_us

set grepprg=ag\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m
"}}}

"{{{ Shortcut mappings
let mapleader = ","
let g:mapleader = ","
let maplocalleader = "\\"
let g:maplocalleader = "\\"

" Avoid accidental hits of <F1> while aiming for <Esc>
noremap! <F1> <Esc>

map <space> <Plug>(easymotion-prefix)

nnoremap ; :
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Use Q for formatting the current paragraph (or visual selection)
vnoremap Q gq
nnoremap Q gqap

" make p in Visual mode replace the selected text with the yank register
vnoremap <silent> p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Complete whole filenames/lines with a quicker shortcut key in insert mode
inoremap <C-f> <C-x><C-f>
inoremap <C-l> <C-x><C-l>

" Quick yanking to the end of the line
nnoremap Y y$

noremap gH H
noremap gL L
noremap gM M
noremap H 0
noremap L $
noremap M ^

inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-y> <C-R>"

vnoremap <silent> <Enter> :EasyAlign<cr>

nmap gx <Plug>(Exchange)
nmap gxx <Plug>(ExchangeLine)
nmap gX <Plug>(ExchangeClear)
vmap gx <Plug>(Exchange)

nnoremap <leader>. @:
nnoremap <leader>a :Ag<Space>
" b subword

nnoremap <silent> <leader>cd :cd %:h<CR>
nnoremap <silent> <leader>cc :bd<cr>

" Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nnoremap <silent> <leader>d "_d
vnoremap <silent> <leader>d "_d

" e subword

nnoremap <leader>f :SyntasticNext<CR>
nnoremap <leader>F :SyntasticNext!<CR>
nnoremap <silent> ]l :lnext<CR>
nnoremap <silent> [l :lprevious<CR>

" shortcut to jump to next conflict marker
nnoremap <silent> <leader>gb :CtrlPBuffer<CR>
nnoremap <silent> <leader>gh :CtrlPF<CR>
nnoremap <silent> <leader>gd :CtrlPZ<CR>
nnoremap <silent> <leader>gf :CtrlPCurFile<CR>
nnoremap <leader>go :grep<Space><Space><C-v>%<Left><Left>
nnoremap <silent> <leader>gr :CtrlPMRUFiles<CR>
nnoremap <leader>g. :e <C-R>=expand('%:h').'/'<cr><C-d>

nnoremap <silent> <leader>i :CtrlPBufTag<CR>
nnoremap <silent> <leader>I :CtrlPBufTagAll<CR>

nnoremap <silent> <leader>lt :TlistToggle<CR>
nnoremap <silent> <leader>ll :NERDTreeToggle<CR>
nnoremap <silent> <leader>lf :NERDTreeFind<CR>
noremap <silent> <leader>lbe :BufExplorer<CR>
noremap <silent> <leader>lbs :BufExplorerHorizontalSplit<CR>
noremap <silent> <leader>lbv :BufExplorerVerticalSplit<CR>

nnoremap <silent> <leader>m :make<CR>
nnoremap <leader>M :compiler<space>
nnoremap <silent> ]e :cnext<CR>
nnoremap <silent> [e :cprevious<CR>

nnoremap <silent> <leader>n :nohlsearch<CR>

nnoremap <silent> <leader>ot :exe "silent !open -a 'Terminal.app' " . shellescape(expand('%:h')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>of :exe "silent !open -R " . shellescape(expand('%')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>om :exe "silent !open -a 'Marked 2.app' " . shellescape(expand('%')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>oM :exe "silent !open -a 'Marked 2.app' " . shellescape(expand('%:h')) . " &> /dev/null" \| :redraw!<cr>
nmap <silent> <leader>oo <Plug>NetrwBrowseX

nnoremap <leader>p "*p
nnoremap <leader>P "*P

" Tame the quickfix window (open/close using ,q)
nnoremap <silent> <leader>Q :QFix<CR>
nnoremap <silent> <leader>q :CtrlPQuickfix<CR>

nnoremap <silent> <leader>sx :call ToggleTodoStatus(0)<cr>
nnoremap <silent> <leader>sX :call ToggleTodoStatus(1)<cr>
vnoremap <silent> <leader>sx :call ToggleTodoStatus(0)<cr>
vnoremap <silent> <leader>sX :call ToggleTodoStatus(1)<cr>
" Strip all trailing whitespace from a file
nnoremap <silent> <leader>sw :%s/\s\+$//e<CR>:let @/=''<CR>:echo "Trailing whitespace cleaned"<CR>

nnoremap <leader>ts :TmuxSend<space>
nnoremap <leader>tS :TmuxSend!<space>
nnoremap <leader>tt :call TmuxRepeat()<cr>
nnoremap <leader>to :TmuxArgs -t<space>
nnoremap <leader>tcd :TmuxSend cd <C-R>=expand('%:p:h').'/'<cr><cr>
nnoremap <leader>tb :TmuxSetBuffer<space>
vnoremap <leader>tb y:TmuxSetBuffer <C-R>"<cr>
vnoremap <leader>ts y:TmuxSend <C-R>"<cr>
vnoremap <leader>tS y:TmuxSend! <C-R>"<cr>

nnoremap <leader>u :GundoToggle<CR>
" Reselect text that was just pasted with ,v
nnoremap <leader>v V`]

" w subword

nnoremap <leader>X :nnoremap ,x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>
nnoremap <leader>x :nnoremap ,x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>
nnoremap <buffer> <localleader>X :nnoremap <buffer> <localleader>x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>
nnoremap <buffer> <localleader>x :nnoremap <buffer> <localleader>x :w\\|!<Space><C-v><CR<C-v>><Left><Left><Left><Left><Left>

nnoremap <leader>y "*y
nnoremap <leader>Y "*yy
vnoremap <leader>y "*y

nnoremap <silent> <leader>/c /^\(<\\|=\\|>\)\{7\}\([^=].\+\)\?$<CR>
nnoremap <silent> <leader>/t /\|.\{-}\|<CR>
nnoremap <silent> <leader>// :nohlsearch<CR>


" search word under cursor
nnoremap <leader>; ;
nnoremap <leader>: ,

"}}}

"{{{ Filetype specific handling
filetype indent plugin on
augroup invisible_chars
  au!

  " Show invisible characters in all of these files
  autocmd filetype vim setlocal list
  autocmd filetype ruby setlocal list
  autocmd filetype javascript,css setlocal list
augroup end

augroup yaml_header_matters
  au!

  autocmd filetype markdown syntax region frontmatter start=/\%^---$/ end=/^---$/
  autocmd filetype markdown highlight link frontmatter Comment
augroup end

augroup restore_position
  au!
  autocmd FileType text setlocal textwidth=78
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END

augroup javascript_ft
  au!

  autocmd BufNewFile,BufRead *.json set ft=javascript
augroup END

augroup spell
  au!
  autocmd FileType gitcommit setlocal spell
augroup END
"}}}
