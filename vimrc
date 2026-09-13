set nocompatible

if has('macunix')
	if has("python3_dynamic")
		set pythonthreedll=/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/Current/Python3
		set pythonthreehome=/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/Current
	endif
endif

if has('python3')
	python3 << EOF
import os
import sys

# httpx only supports ('http', 'https', 'socks5')
from urllib.parse import urlparse
for var in ('HTTP_PROXY', 'http_proxy', 'HTTPS_PROXY', 'https_proxy', 'ALL_PROXY', 'all_proxy'):
    if var in os.environ:
        url_str = os.environ[var]
        try:
            parsed = urlparse(url_str)
            if parsed.scheme not in ('http', 'https', 'socks5'):
                del os.environ[var]
        except Exception:
            del os.environ[var]

py_ver = '%d.%d' % (sys.version_info.major, sys.version_info.minor)
venv_home = os.path.expanduser('~/.virtualenvs/%s' % py_ver)
os.environ['VIRTUAL_ENV'] = venv_home
os.environ['PATH'] = os.path.join(venv_home, 'bin') + os.pathsep + os.environ.get('PATH', '')
sys.prefix = venv_home

site_packages = os.path.join(venv_home, 'lib', 'python%s' % py_ver, 'site-packages')
if os.path.exists(site_packages) and site_packages not in sys.path:
	sys.path.insert(0, site_packages)
EOF

endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype off
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'gergap/vim-ollama'
Plugin 'thirtythreeforty/lessspace.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/fzf', { 'do': { -> fz#install() } }
Plugin 'junegunn/fzf.vim'
Plugin 'preservim/tagbar'
Plugin 'thinca/vim-localrc'
Plugin 'mhinz/vim-signify' ", { 'tag': 'legacy' }
Plugin 'Yggdroot/indentLine'
Plugin 'kovisoft/slimv'
call vundle#end()
filetype plugin indent on
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Explanation about tabstop, shiftwidth, softtabstop and expandtab
"   https://arisweedler.medium.com/tab-settings-in-vim-1ea0863c5990
set tabstop=4
set shiftwidth=4

set foldmethod=syntax
set nofoldenable

set mouse=a
set wildmenu
set number
set ruler
set showmatch
set showcmd
set hlsearch
set nowrap
set hidden
set history=1024
set display+=lastline
set colorcolumn=100
set noswapfile
set nowritebackup
set nobackup
set modeline
set modelines=3
set history=512
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,gbk,gb18030,gb2312,ucs-bom,cp936,latin1
syntax enable
syntax on
if has("gui_running")
	set cursorline
endif

" Disable LaTeX symbol conversion
let g:tex_conceal = ""

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
xnoremap <silent> <leader>y "+y
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
if executable('rg')
	let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow --ignore-file ' . expand('~/.ignore')
	command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case --ignore-file " . shellescape(expand('~/.ignore')) . " -- ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)'
elseif executable('ag')
	let $FZF_DEFAULT_COMMAND='ag --path-to-ignore ' . expand('~/.ignore') . ' -g ""'
endif

nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>/ :Rg<CR>
nnoremap <silent> <leader>h :History<CR>

" config vim-ollama
let g:ollama_model      = 'qwen2.5-coder:1.5b-base' " code completion model
let g:ollama_edit_model = 'llama3.2:3b'
let g:ollama_chat_model = 'llama3.2:3b'

"nnoremap <leader>c :OllamaChat<CR>
"vnoremap <leader>e :OllamaEdit<CR>
let g:ollama_debounce_time = 0
" <C-j> == <Char-10>
inoremap <Char-10> <Plug>(ollama-trigger-completion)

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

" config Slimv
let g:slimv_repl_split=0
let g:paredit_mode=0             " Disable auto insert of matched characters
let g:slimv_clhs_root="file://$HOME/Sourcery/quicklisp/dists/quicklisp/software/clhs-0.6.3/HyperSpec-7-0/HyperSpec/Body/"
let g:swank_host='win7x86.local'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
    " https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
    function! MyHighlights() abort
        highlight ColorColumn ctermbg=Red guibg=Red
        highlight SignColumn ctermbg=NONE guibg=NONE
    endfunction

    autocmd FileType make   set noexpandtab
    autocmd FileType python set expandtab foldmethod=indent
    autocmd ColorScheme * call MyHighlights()

    if has("gui_running")
        set autoread | au CursorHold * checktime | call feedkeys("lh")
        autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
    endif
endif

" Platform specific
if (has("win32"))
	if has("gui")
		set guifont=Consolas:h12:cANSI
   		set guifontwide=NSimsun:h12
	endif

    if (has("gui_running"))
        set termencoding=utf-8
        set langmenu=zh_CN.UTF-8

        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim

        language message zh_CN.UTF-8
    endif
elseif (has("win32unix"))
    set termencoding=gbk
elseif (has("macunix"))
	if has("gui")
		set guifont=DejaVuSansMNFM:h18
	endif

	let s:theme = system('defaults read -g AppleInterfaceStyle >/dev/null 2>&1')
	if v:shell_error
		"
	else
		"
	endif

    colorscheme industry
else
	if has("gui")
    	set guifont=Monospace\ 12
	endif
    if has("gui_running")
        "set guioptions-=m
        "set guioptions-=T
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256
        endif
    endif

    colorscheme industry
endif
