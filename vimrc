if v:progname =~? "evim"
  finish
endif
set nocompatible
scriptencoding utf-8
set encoding=utf-8

" Vundle {{{1
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Plugin 'gmarik/vundle'

Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'Gundo'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'altercation/vim-colors-solarized'
Plugin 'amiorin/ctrlp-z'
Plugin 'bkad/CamelCaseMotion'
Plugin 'bling/vim-airline'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'edkolev/erlang-motions.vim'
Plugin 'elixir-lang/vim-elixir'
Plugin 'junegunn/vim-easy-align'
Plugin 'kana/vim-textobj-indent'
Plugin 'kana/vim-textobj-lastpat'
Plugin 'kana/vim-textobj-user'
Plugin 'kchmck/vim-coffee-script'
Plugin 'kien/ctrlp.vim'
Plugin 'mattn/emmet-vim'
Plugin 'rizzatti/dash.vim'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/syntastic'
Plugin 'slim-template/vim-slim'
Plugin 'thinca/vim-visualstar'
Plugin 'tommcdo/vim-exchange'
Plugin 'tomtom/tcomment_vim'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-dispatch'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-projectionist'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-rake'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-vinegar'
Plugin 'vim-ruby/vim-ruby'

" Plugin 'SirVer/ultisnips'
" Plugin 'honza/vim-snippets

" Theme {{{1
if has("gui_running")
  set guifont=Source\ Code\ Pro\ Medium:h16

  " Remove toolbar, left scrollbar and right scrollbar
  set guioptions-=TlLrR
  set guicursor+=a:blinkwait2000-blinkon1500 " blink slowly
  set mousehide		" Hide the mouse when typing text

  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>
endif

set noshowmode
"set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l
if has("mac")
  let g:airline_powerline_fonts=1
endif

if &t_Co > 2 || has("gui_running")
  syntax on
endif
if &t_Co < 256
  let g:solarized_termcolors=256
endif
colors solarized
set bg=dark

hi MatchParen cterm=bold ctermbg=none ctermfg=red gui=bold guibg=NONE guifg=red

" Plugins Options {{{1
let Tlist_Exit_OnlyWindow=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_WinWidth=40
let Tlist_Inc_Winwidth=0
let Tlist_Use_Right_Window=1

let g:ctrlp_root_markers = []
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_map = '<leader>,'
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|_build)$',
  \ }
let g:ctrlp_extensions = ['Z', 'F']

" syntastic
let g:syntastic_mode_map = { "mode": "passive",
                           \ "active_filetypes": [],
                           \ "passive_filetypes": [] }
let g:syntastic_auto_loc_list = 1

let g:user_emmet_settings = {
      \ 'indentation' : '  '
      \ }

" Functions & Commands {{{1
function! EchoError(msg)
  execute "normal \<Esc>"
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

function! ExecAndShowError(command)
  let v:errmsg = ""
  silent! exec a:command
  if v:errmsg != ""
    call EchoError(v:errmsg)
  endif
endfunction

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
    try
      silent lnext
    catch /E553/
      call SyntasticNext(1)
    endtry
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

command! Reload :source ~/.vimrc | :filetype detect
command! Clear :CtrlPClearCache | :bufdo bd | :silent! argd *
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

" wrapper function to restore the cursor position, window position,
" and last search after running a command.
function! Preserve(command)
  " Save the last search
  let last_search=@/
  " Save the current cursor position
  let save_cursor = getpos(".")
  " Save the window position
  normal H
  let save_window = getpos(".")
  call setpos('.', save_cursor)
 
  " Do the business:
  execute a:command
 
  " Restore the last_search
  let @/=last_search
  " Restore the window position
  call setpos('.', save_window)
  normal zt
  " Restore the cursor position
  call setpos('.', save_cursor)
endfunction

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright 5new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  " call setline(1, 'You entered:    ' . a:cmdline)
  " call setline(2, 'Expanded Form:  ' .expanded_cmdline)
  " call setline(3,substitute(getline(2),'.','=','g'))
  execute '$read !'. expanded_cmdline
  setlocal nomodifiable
  1
endfunction

" Config {{{1
set expandtab
set shiftwidth=2
set shiftround
set backspace=indent,eol,start
set autoindent
set copyindent
" set number
set ignorecase
set smartcase
set smarttab
set scrolloff=2
set virtualedit="block,insert"
set hlsearch
set incsearch
set listchars=tab:▸\ ,trail:·,extends:#,nbsp:·
set pastetoggle=<F12>
set fileformats="unix,dos,mac"
set formatoptions+=1

set foldmethod=marker
set foldlevelstart=0
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
  set undodir=~/.vim/.undo,/tmp
endif
if has("vms")
  set nobackup
else
  set backup
endif
set backupdir=~/.vim/backup//
set viminfo='30,\"80
set wildmenu
set wildmode=list:longest,full
set wildignore=*.swp,*.bak,*.pyc,*.class,*.beam
set title
set visualbell
set noerrorbells
set cursorline
" set ruler

set spellfile=$HOME/.vim-spell-en.utf-8.add
set spelllang=en_us

set grepprg=ag\ --vimgrep\ $*
set grepformat=%f:%l:%c:%m

" Shortcut mappings {{{1
let mapleader = ","
let g:mapleader = ","
let maplocalleader = "\\"
let g:maplocalleader = "\\"

" Avoid accidental hits of <F1> while aiming for <Esc>
noremap! <F1> <Esc>

map <space> <Plug>(easymotion-prefix)

cnoremap %p <C-R>=expand('%:p')<cr>
cnoremap %h <C-R>=expand('%:h').'/'<cr>
cnoremap %t <C-R>=expand('%:t')<cr>
cnoremap %% <C-R>=expand('%')<cr>
noremap <leader>%p i<C-R>=expand('%:p')<cr><Esc>
noremap <leader>%h i<C-R>=expand('%:h').'/'<cr><Esc>
noremap <leader>%t i<C-R>=expand('%:t')<cr><Esc>
noremap <leader>%% i<C-R>=expand('%')<cr><Esc>

nnoremap ; :
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bNext<CR>

" Use Q for formatting the current paragraph (or visual selection)
vnoremap Q gq
nnoremap Q gqap

" make p in Visual mode replace the selected text with the yank register
vnoremap <silent> p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

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
inoremap <C-y><C-y> <C-R>"

vnoremap <silent> <Enter> :EasyAlign<cr>

nmap gx <Plug>(Exchange)
nmap gxx <Plug>(ExchangeLine)
nmap gX <Plug>(ExchangeClear)
vmap gx <Plug>(Exchange)

nnoremap <silent> <leader>. :CtrlPClearAllCaches<cr>
nnoremap <silent> <leader>1 <C-w>o
nnoremap <silent> <leader>2 <C-w>o<C-w>s<C-w>w:b#<CR><C-w>w
nnoremap <silent> <leader>3 <C-w>o<C-w>v<C-w>w:b#<CR><C-w>w

nnoremap <leader>a :A<cr>

" b subword

nnoremap <silent> <leader>cd :cd %:h<CR>
nnoremap <silent> <leader>cc :bd<cr>

" Use ,d (or ,dd or ,dj or 20,dd) to delete a line without adding it to the
" yanked stack (also, in visual mode)
nnoremap <silent> <leader>d "_d
vnoremap <silent> <leader>d "_d

" e subword

nnoremap <silent> <leader>f :SyntasticNext<CR>
nnoremap <leader>F :SyntasticNext!<CR>
nnoremap <silent> ]l :lnext<CR>
nnoremap <silent> [l :lprevious<CR>

" shortcut to jump to next conflict marker
nnoremap <silent> <leader>gb :CtrlPBuffer<CR>
nnoremap <silent> <leader>gd :CtrlPDir<CR>
nnoremap <silent> <leader>gh :CtrlPF<CR>
nnoremap <silent> <leader>gz :CtrlPZ<CR>
nnoremap <silent> <leader>gf :CtrlPCurFile<CR>
nnoremap <leader>go :grep<Space><Space><C-v>%<Left><Left>
nnoremap <silent> <leader>gr :CtrlPMRUFiles<CR>
nnoremap <leader>g. :e <C-R>=expand('%:h').'/'<cr>
nnoremap <silent> <leader>gt :CtrlPTag<CR>

nmap <silent> <leader>h <Plug>DashSearch
nmap <silent> <leader>H <Plug>DashGlobalSearch

nnoremap <silent> <leader>i :CtrlPBufTag<CR>
nnoremap <silent> <leader>I :CtrlPBufTagAll<CR>

" UNUSED j, k

nnoremap <silent> <leader>lt :TlistToggle<CR>
nmap <silent> <leader>ll <Plug>VinegarUp
nmap <silent> <leader>lv <Plug>VinegarVerticalSplitUp
noremap <silent> <leader>lbe :BufExplorer<CR>
noremap <silent> <leader>lbs :BufExplorerHorizontalSplit<CR>
noremap <silent> <leader>lbv :BufExplorerVerticalSplit<CR>

nnoremap <silent> <leader>m :Dispatch<CR>
nnoremap <silent> <leader>M :Dispatch!<CR>
nnoremap <silent> ]e :cnext<CR>
nnoremap <silent> [e :cprevious<CR>

nnoremap <silent> <leader>n :nohlsearch<CR>

nnoremap <silent> <leader>ot :exe "silent !open -a 'Terminal.app' " . shellescape(expand('%:h')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>of :exe "silent !open -R " . shellescape(expand('%')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>om :exe "silent !open -a 'Marked 2.app' " . shellescape(expand('%')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>oM :exe "silent !open -a 'Marked 2.app' " . shellescape(expand('%:h')) . " &> /dev/null" \| :redraw!<cr>
nnoremap <silent> <leader>oo :exe "silent !open " . shellescape(expand('%')) . " &> /dev/null" \| :redraw!<cr>
nmap <silent> <leader>ob <Plug>NetrwBrowseX

nnoremap <leader>p "*p
nnoremap <leader>P "*P

" Tame the quickfix window (open/close using ,q)
nnoremap <silent> <leader>Q :QFix<CR>
nnoremap <silent> <leader>q :CtrlPQuickfix<CR>

" OmniFocus
nnoremap <silent> <leader>r :silent exe "Start osascript -e 'tell application \"OmniFocus\" to tell quick entry' -e 'make new inbox task with properties {name:\"%:t\",note:\"mvim://open?line=" . line(".") . "&url=file://%:p\"}' -e 'open' -e 'end tell' &> /dev/null"<cr>

nnoremap <silent> <leader>sx :call ToggleTodoStatus(0)<cr>
nnoremap <silent> <leader>sX :call ToggleTodoStatus(1)<cr>
vnoremap <silent> <leader>sx :call ToggleTodoStatus(0)<cr>
vnoremap <silent> <leader>sX :call ToggleTodoStatus(1)<cr>
" Strip all trailing whitespace from a file
nnoremap <silent> <leader>sw :%s/\s\+$//e<CR>:let @/=''<CR>:echo "Trailing whitespace cleaned"<CR>

nnoremap <leader>tm :Make<cr>
nnoremap <leader>tb :Make!<cr>
nnoremap <leader>to :Copen<cr>
nnoremap <leader>td :Dispatch<space>
nnoremap <leader>ts :Start<space>
nnoremap <leader>tf :Focus<space>

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

" UNUSED z

nnoremap <silent> <leader>/c /^\(<\\|=\\|>\)\{7\}\([^=].\+\)\?$<CR>
nnoremap <silent> <leader>/t /\|.\{-}\|<CR>
nnoremap <silent> <leader>// :nohlsearch<CR>


" search word under cursor
nnoremap <leader>; ;
nnoremap <leader>: ,

" Filetype specific handling {{{1
filetype indent plugin on
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

augroup jinjia2_ft
  au!

  autocmd BufNewFile,BufRead *.j2 set ft=jinja
augroup END

augroup spell
  au!
  autocmd FileType gitcommit setlocal spell
augroup END

autocmd FileType netrw setl bufhidden=wipe
