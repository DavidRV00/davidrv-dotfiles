" Enable modern Vim features not compatible with Vi spec.
set nocompatible

"==============="
" Basic options "
"==============="

set tabpagemax=300
set splitbelow
set splitright
set number
set clipboard=unnamedplus
set linebreak
set relativenumber
set showtabline=1
set mouse=a
set ttymouse=xterm2

" For some reason, for Go formatting I need to copy these lines into
" ~/.vim/after/ftplugin/go.vim
set tabstop=2
set shiftwidth=2

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Automatically change the working path to the path of the current file.
" Really only want this for working in very large directory structure where you
" might have multiple 'homes'.
augroup setpath
  autocmd BufNewFile,BufEnter * silent! lcd %:p:h
augroup END
let g:netrw_keepdir=0

" Don't let netrw screw up line numbering
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" Tree view in netrw
let g:netrw_liststyle=3

" Remove trailing whitespace on save
function! RemoveWhitespace()
  let save_pos = getpos(".")
  execute "normal! :%s/\\s\\+$//e\<cr>"
  call setpos('.', save_pos)
endfunction
augroup whitespace
  autocmd BufWritePre * call RemoveWhitespace()
augroup END

" Make it so that autoread triggers when the cursor is still and when changing
" buffers (autoread is added by vim-sensible).
augroup autoread
  au CursorHold,CursorHoldI * checktime
  au FocusGained,BufEnter * checktime
augroup END

" Automatically toggle 'set paste' when pasting.
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif
  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"
  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction
let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" Rename tabs to show tab number.
" (Based on http://stackoverflow.com/questions/5927952
"       /whats-implementation-of-vims-default-tabline-function)
if exists("+showtabline")
  function! MyTabLine()
    let s = ''
    let wn = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      let s .= '%' . i . 'T'
      "let s .= (i == t ? '%1*' : '%2*')
      "let s .= ' '
      let wn = tabpagewinnr(i,'$')
      "let s .= '%#TabNum#'
      let s .= (i == t ? '%#TabLineSel#' : '%#TabNum#')
      let s .= i
      "let s .= '%*'
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      let bufnr = buflist[winnr - 1]
      let file = bufname(bufnr)
      let buftype = getbufvar(bufnr, 'buftype')
      if buftype == 'nofile'
        if file =~ '\/.'
          let file = substitute(file, '.*\/\ze.', '', '')
        endif
      else
        let file = fnamemodify(file, ':p:t')
      endif
      if file == ''
        let file = '[No Name]'
      endif
      let s .= ':' . file . '%#TabLine# '
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    let s .= '%#TabLineSel# vim '
    return s
  endfunction
  set stal=2
  set tabline=%!MyTabLine()
  set showtabline=1
  "set showtabline=2
  highlight link TabNum Special
endif

" Maps
let mapleader = "-"
let maplocalleader = ";"
inoremap kj <Esc>
vnoremap KJ <Esc>
inoremap <leader>w <Esc>:<C-u>w<CR>
nnoremap <leader>w :<C-u>w<CR>
nnoremap <leader>sv :<C-u>source ~/.vimrc<CR>
nnoremap <leader>v :<C-u>vsplit<CR>
nnoremap <leader>b :<C-u>split<CR>
nnoremap <leader>t :<C-u>tabnew .<CR>
nnoremap <leader>e :<C-u>e<Space>
nnoremap === <C-w>=
nnoremap <PageUp> gt
nnoremap <PageDown> gT
nnoremap gr gT
"nnoremap <Tab> gt
"nnoremap <S-Tab> gT
nnoremap <leader>lc :set cursorline!<CR>
nnoremap <leader>z vi{zf
" Are the p ones really necessary? They might just paste FROM reg 0, meanwhile
" the d one already has deleting TO reg 0 (incl in p and c) covered.
"vnoremap p "0p
"vnoremap P "0P
"nnoremap d "0d
nnoremap <leader>] :cn<CR>
nnoremap <leader>[ :cp<CR>
nnoremap <leader>sb :<C-u>sb<Space>
"nnoremap <leader>eb :<C-u>b<Space>
nnoremap <leader>B :<C-u>:ls<CR>:b<Space>
nnoremap <leader>nt :Ntree<CR>ggj
nnoremap <leader>fm :!ranger $PWD<CR>
nnoremap <leader>G :vimgrep //g **/*<Left><Left><Left><Left><Left><Left><Left>
nnoremap <leader>S :%s///g<Left><Left><Left>
nnoremap <leader>X :!sudo chmod a+x %<CR>
nnoremap cl :<C-u>pclose <bar> lclose <bar> cclose<CR>
nnoremap co :<C-u>copen<CR>
nnoremap <leader>ct :execute "set colorcolumn=" . (&colorcolumn == "" ? "101" : "")<CR>

" Autoclose parens, brackets, etc...
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {}<Esc>i
inoremap {<CR> {<CR>}<Esc>O
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
"inoremap } <c-r>=CloseBracket()<CR>
inoremap } <c-r>=ClosePair('}')<CR>
inoremap " <c-r>=QuoteDelim('"')<CR>
"inoremap ' <c-r>=QuoteDelim("'")<CR>
"augroup htmlcarrots
"  autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
"augroup END

function! ClosePair(char)
  if getline('.')[col('.') - 1] == a:char
  return "\<Right>"
  else
  return a:char
  endif
endf

"function CloseBracket()
" if match(getline(line('.') + 1), '\s*}') < 0
" return "\<CR>}"
" else
" return "\<Esc>j0f}a"
" endif
"endf

function! QuoteDelim(char)
  let line = getline('.')
  let col = col('.')
  if line[col - 2] == "\\"
  "Inserting a quoted quotation mark into the string
  return a:char
  elseif line[col - 1] == a:char
  "Escaping out of the string
  return "\<Right>"
  else
  "Starting a string
  return a:char.a:char."\<Esc>i"
  endif
endf

" Change cursor depending on mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
augroup myCmds
  au!
  autocmd VimEnter * silent !echo -ne "\e[2 q"; echo ''
augroup END

" Edit and run jupyter-notebook-style scripts from Vim
source $HOME/.vim/jupyterrun.vim

" Netrw-specific maps
nmap <Leader>- <Plug>VinegarUp
nnoremap - -
"augroup netrw_mapping
"    autocmd!
"    autocmd filetype netrw call NetrwMapping()
"augroup END
"
"function! NetrwMapping()
"    "noremap <buffer> a
"endfunction

"========================================="
" Vundle configuration / External plugins "
"========================================="

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('$HOME/.vim/bundle/Vundle.vim'))
  call vundle#begin()
  Plugin 'VundleVim/Vundle.vim' " Let Vundle manage Vundle, required.

  Plugin 'tpope/vim-sensible' " Sensible defaults

  Plugin 'vim-scripts/netrw.vim' " Basic default file navigator
  Plugin 'tpope/vim-vinegar' " Enhancements for netrw

  Plugin 'tpope/vim-obsession' " Persist vim sessions

  " Syntastic (syntax checking)
  "Plugin 'scrooloose/syntastic'
  "set statusline+=%#warningmsg#
  "set statusline+=%{SyntasticStatuslineFlag()}
  "set statusline+=%*
  "let g:syntastic_always_populate_loc_list = 1
  "let g:syntastic_auto_loc_list = 1
  "let g:syntastic_check_on_open = 1
  "let g:syntastic_check_on_wq = 1
  "let g:syntastic_go_checkers = ['go', 'golint', 'govet'] " go

  Plugin 'scrooloose/nerdcommenter' " Better commenting
  let g:NERDCommentEmptyLines = 1
  let g:NERDDefaultAlign = 'left'
  let g:NERDToggleCheckAllLines = 1

  " Smooth navigation between tmux panes and vim buffers with ctrl-direction
  Plugin 'christoomey/vim-tmux-navigator'

  " Snippets
  Plugin 'SirVer/ultisnips'
  Plugin 'honza/vim-snippets'
  let g:ycm_key_list_select_completion=["<tab>"]
  let g:ycm_key_list_previous_completion=["<S-tab>"]
  "let g:UltiSnipsJumpForwardTrigger="<tab>"
  "let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
  let g:UltiSnipsJumpForwardTrigger="<CR>"
  let g:UltiSnipsJumpBackwardTrigger="<S-CR>"
  let g:UltiSnipsExpandTrigger="<nop>"
  let g:ulti_expand_or_jump_res = 0
  function! <SID>ExpandSnippetOrReturn()
  let snippet = UltiSnips#ExpandSnippetOrJump()
  if g:ulti_expand_or_jump_res > 0
    return snippet
  else
    return "\<CR>"
  endif
  endfunction
  inoremap <expr> <CR> pumvisible() ? "<C-R>=<SID>ExpandSnippetOrReturn()<CR>" : "\<CR>"

  " Fzf
  set rtp+=~/.fzf
  Plugin 'junegunn/fzf.vim'
  " Customize fzf colors to match your color scheme
  "let g:fzf_colors =
  "\ { 'fg':    ['fg', 'Normal'],
  "\ 'bg':    ['bg', 'Normal'],
  "\ 'hl':    ['fg', 'Comment'],
  "\ 'fg+':   ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  "\ 'bg+':   ['bg', 'CursorLine', 'CursorColumn'],
  "\ 'hl+':   ['fg', 'Statement'],
  "\ 'info':  ['fg', 'PreProc'],
  "\ 'border':  ['fg', 'Ignore'],
  "\ 'prompt':  ['fg', 'Conditional'],
  "\ 'pointer': ['fg', 'Exception'],
  "\ 'marker':  ['fg', 'Keyword'],
  "\ 'spinner': ['fg', 'Label'],
  "\ 'header':  ['fg', 'Comment'] }

  " LaTeX editing
  Plugin 'lervag/vimtex'

  " Surround selection with things
  Plugin 'tpope/vim-surround'

  " Send text to tmux panes
  "Plugin 'esamattis/slimux' " Has bugs with unmerged pull-requests
  Plugin 'lotabout/slimux'
  let g:slimux_python_use_ipython=1
  let g:slimux_python_press_enter=1

  " Asynchronous external commands
  Plugin 'tpope/vim-dispatch'

  " Highlight instances of current word
  "Plugin 'dominikduda/vim_current_word'
  "
  " Colorschemes
  Plugin 'flazz/vim-colorschemes'

  " Airline
  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'

  " Better opening from quickfix
  Plugin 'yssl/QFEnter'

  Plugin 'vim-scripts/vcscommand.vim'

  " Load non-portable plugins and settings
  source $HOME/.vim_vundle_noport.vim

  call vundle#end()
else
  echomsg 'Vundle is not installed. You can install Vundle from'
    \ 'https://github.com/VundleVim/Vundle.vim'
endif

source $HOME/.vim_noport.vim

" Enable file type based indentation
" This must be done AFTER loading plugins and sourcing configuration.
filetype plugin indent on
syntax on

" Notebook conceal
augroup py
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=_
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=¶
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=»
  autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=―
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=━
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=┈
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=⎯
  autocmd BufNewFile,BufRead *.py,*.r,*.R :set conceallevel=1
  autocmd BufNewFile,BufRead *.py,*.r,*.R :set concealcursor=nc
augroup END

" Auto-write latex files if cursor is held still (then vimtex compiles on save)
augroup tex
  autocmd BufNewFile,BufRead *.tex :VimtexCompile
  autocmd BufNewFile,BufRead *.tex :set updatetime=500
  autocmd CursorHold *.tex :update
  autocmd CursorHoldI *.tex :update
augroup END

" Auto draw graphviz files
augroup gv
  autocmd BufWritePost *.gv :silent !dot -Tpng % -o %.png
augroup END

" Appearance
set background=dark

"colorscheme Atelier_CaveDark
"colorscheme 1989
"colorscheme OceanicNext
colorscheme blues

"let g:airline_theme='base16_eighties'
"let g:airline_theme='base16_ashes'
"let g:airline_theme='badwolf'
let g:airline_theme='behelit'
"let g:airline_theme='biogoo'
"let g:airline_theme='fairyfloss'
"let g:airline_theme='jet'
"let g:airline_theme='base16_google'

"let g:airline_section_c = airline#section#create(['%-20f'])
"let g:airline_section_gutter = airline#section#create([' ---------------------------- %='])
let g:airline_section_z = airline#section#create_right(['%l','%c'])

"function! AirlineInit()
"  "let g:airline_section_a = airline#section#create(['filetype'])
"  "let g:airline_section_z = ""
"  "let g:airline_section_z = airline#section#create_right(['%l','%c'])
"endfunction
"autocmd VimEnter * call AirlineInit()

set cursorline

"let &colorcolumn=join(range(101,999),",")

hi! ColorColumn ctermbg=232
hi! LineNr ctermbg=232 ctermfg=236
hi! CursorLineNr cterm=NONE ctermbg=232 ctermfg=68
hi! CursorLine cterm=NONE ctermbg=233
hi! TabLineFill ctermfg=234 ctermbg=234
hi! TabLineSel ctermbg=236 ctermfg=75
hi! TabLine ctermbg=234 cterm=None
hi! TabNum ctermbg=234 ctermfg=None
hi! Pmenu ctermbg=24 ctermfg=16
hi! PmenuSel ctermbg=16 ctermfg=39
hi! Conceal ctermfg=68 ctermbg=NONE
hi! VertSplit ctermbg=16 ctermfg=16
hi! SignColumn ctermbg=233
hi! EndOfBuffer ctermbg=232
hi! StatusLine ctermfg=247 ctermbg=16
hi! StatusLineNC ctermfg=16 ctermbg=16
hi! WildMenu ctermbg=236 ctermfg=39
"hi! link QuickFixLine PmenuSel
