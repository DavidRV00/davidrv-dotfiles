" Enable modern Vim features not compatible with Vi spec.
set nocompatible

"==============="
" Basic options "
"==============="

colorscheme delek
set tabpagemax=300
set splitbelow
set splitright
set number

" For some reason, for Go formatting I need to copy these lines into
" ~/.vim/after/ftplugin/go.vim
set tabstop=2
set shiftwidth=2

" Automatically change the working path to the path of the current file.
autocmd BufNewFile,BufEnter * silent! lcd %:p:h
let g:netrw_keepdir=0

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Make it so that autoread triggers when the cursor is still and when changing
" buffers (autoread is added by vim-sensible).
au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * checktime

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

" Relative line numbers in current tab, absolute in other tabs
if has('autocmd')
augroup vimrc_linenumbering
  autocmd!
  autocmd WinLeave *
  \ if &number |
  \   set norelativenumber |
  \ endif
  autocmd WinEnter *
  \ if &number |
  \   set relativenumber |
  \ endif
  autocmd VimEnter *
  \ if &number |
  \   set relativenumber |
  \ endif
augroup END
endif

" Don't let netrw screw up line numbering
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" Tree view in netrw
let g:netrw_liststyle=3

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
      let s .= (i == t ? '%1*' : '%2*')
      let s .= ' '
      let wn = tabpagewinnr(i,'$')

      let s .= '%#TabNum#'
      let s .= i
      " let s .= '%*'
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
      let s .= ' ' . file . ' '
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction
  set stal=2
  set tabline=%!MyTabLine()
  set showtabline=1
  highlight link TabNum Special
endif

" Autoclose parens, brackets, etc...
inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {}<Esc>i
inoremap {<CR> {<CR>}<Esc>O
autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
"inoremap } <c-r>=CloseBracket()<CR>
inoremap } <c-r>=ClosePair('}')<CR>
inoremap " <c-r>=QuoteDelim('"')<CR>
inoremap ' <c-r>=QuoteDelim("'")<CR>

function ClosePair(char)
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

function QuoteDelim(char)
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
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

" Maps
let mapleader = "-"
let maplocalleader = "\\"
inoremap kj <Esc>
inoremap <leader>w <Esc>:<C-u>w<CR>
nnoremap <leader>w :<C-u>w<CR>
nnoremap <leader>sv :<C-u>source ~/.vimrc<CR>
nnoremap <PageUp> gt
nnoremap <PageDown> gT
nnoremap <Tab> gt
nnoremap <S-Tab> gT
nnoremap <leader>lc :set cursorline!<CR>
nnoremap <leader>z vi{zf
" Are the p ones really necessary? They might just paste FROM reg 0, meanwhile
" the d one already has deleting TO reg 0 (incl in p and c) covered.
vnoremap p "0p
vnoremap P "0P
nnoremap d "0d
nnoremap <leader>] :cn<CR>
nnoremap <leader>[ :cp<CR>

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

" Auto-write latex files if cursor is held still (then vimtex compiles on save)
autocmd BufNewFile,BufRead *.tex :VimtexCompile
autocmd BufNewFile,BufRead *.tex :set updatetime=500
autocmd CursorHold *.tex :update
autocmd CursorHoldI *.tex :update
