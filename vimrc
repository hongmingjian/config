set nocompatible

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:session_vim_enter()
    if bufnr('$') == 1 && bufname('%') == '' && !&mod && getline(1, '$') == ['']
        execute 'silent source ~/.vim/lastsession.vim'
    else
      let s:session_loaded = 0
    endif
endfunction

function! s:session_vim_leave()
  if s:session_loaded == 1
    let sessionoptions = &sessionoptions
    try
        set sessionoptions-=options
        set sessionoptions+=tabpages
        execute 'mksession! ~/.vim/lastsession.vim'
    finally
        let &sessionoptions = sessionoptions
    endtry
  endif
endfunction

" https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyHighlights() abort
    highlight ColorColumn ctermbg=Red guibg=Red
    highlight SignColumn ctermbg=NONE guibg=NONE
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype off
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'Valloric/YouCompleteMe'
Plugin 'thirtythreeforty/lessspace.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf', { 'do': { -> fz#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'preservim/tagbar'
Plugin 'thinca/vim-localrc'
Plugin 'mhinz/vim-signify' ", { 'tag': 'legacy' }
Plugin 'Yggdroot/indentLine'
call vundle#end()
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Explanation about tabstop, shiftwidth, softtabstop and expandtab
" https://arisweedler.medium.com/tab-settings-in-vim-1ea0863c5990
"
set tabstop=4
set shiftwidth=4

set foldmethod=syntax
set nofoldenable

set mouse=a
set number
set ruler
set showmatch
set showcmd
set hlsearch
set nowrap
set hidden
set history=1024
set display+=lastline
set colorcolumn=120
set noswapfile

syntax enable
syntax on

let mapleader = "\<Space>"

" Fix Ctrl+Arrows
if &term == "screen"
    map <esc>[1;5A <C-Up>
    map <esc>[1;5B <C-Down>
    map <esc>[1;5C <C-Right>
    map <esc>[1;5D <C-Left>
endif

" Buffer navigation
" https://dev.to/iggredible/using-buffers-windows-and-tabs-efficiently-in-vim-56jc
map <C-K> :bfirst<CR>
map <C-J> :blast<CR>
map <C-H> :bprevious<CR>
map <C-L> :bnext<CR>
map <C-W> :bdelete<CR>
nnoremap <leader>b :buffers<CR>:buffer<Space>

" Fold/Unfold
nnoremap <silent> <leader> za

" Copy & Paste from/to system clipboard
vnoremap <silent> <leader>y "+y
nnoremap <silent> <leader>p "+p

" Clear highlight until next search
nnoremap <CR> :noh<CR><CR>

if has('cscope')
    function! Load_csdb(csdbpath)
        let csdbpath = expand(a:csdbpath)

        if !filereadable(csdbpath)
            return
        endif

        let save_csvb = &csverb

        set nocsverb
        exe "cs kill " . csdbpath
        exe "cs add " . csdbpath

        let &csverb = save_csvb
    endfunc

    set csto=0
    set cst

    "Find functions calling this function
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>

    "Find functions called by this function
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

    "Find this definition
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>

    "Find all references to this symbol
    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>

    "Open this file
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
endif

" config fzf
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>/ :Rg<CR>
nnoremap <silent> <leader>h :History<CR>

" config ycm
let g:ycm_confirm_extra_conf=0
let g:ycm_auto_trigger=0         "<C-Space> for manual trigger
let g:ycm_auto_hover=''
let g:ycm_show_diagnostics_ui=0
set completeopt-=preview

" config tagbar
map <F12> :TagbarToggle<CR>

" config airline
" let g:airline_theme='dark'
let g:airline_powerline_fonts=1
let g:airline#extensions#whitespace#enabled=0
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_tabs=0
let g:airline#extensions#tabline#show_buffers=1
let g:airline#extensions#tabline#formatter='unique_tail'
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline#extensions#tabline#buffer_nr_format='%s:'

" config signify
set signcolumn=yes
"set updatetime=1000

if has("autocmd")
    autocmd FileType make   set noexpandtab
    autocmd FileType python set expandtab foldmethod=indent

    " Remember position of last edit and return on reopen
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    let s:session_loaded = 1
    augroup autosession
        " load last session on start
        " Note: without 'nested' filetypes are not restored.
        autocmd VimEnter * nested call s:session_vim_enter()
        autocmd VimLeavePre * call s:session_vim_leave()
    augroup END

    autocmd ColorScheme * call MyHighlights()

    if has("gui_running")
        set autoread | au CursorHold * checktime | call feedkeys("lh")
        autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
    endif
endif

if has("gui_running")
    "set guioptions-=m
    "set guioptions-=T
    set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12

    "highlight ColorColumn guibg=DimGray
else
    if &term == 'xterm' || &term == 'screen'
        set t_Co=256
    endif

    colorscheme industry
endif