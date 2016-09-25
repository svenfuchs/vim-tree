let &runtimepath.=','.escape(expand('<sfile>:p:h'), '\,')
source ./plugin/tree.vim
au VimEnter * exe ":VimTree"

filetype plugin indent on
se nocompatible

colorscheme smyck
se background=dark

syntax on                      " syntax highlighting

se encoding=utf-8
se nocompatible
se nobackup
se nowritebackup
se noswapfile
se history=1000
se viminfo+=n~/.vim/.viminfo

se timeout timeoutlen=500 ttimeoutlen=-1
se autoread                   " auto read files changed outside of vim
se hidden

se nowrap
se lbr
se tabstop=2
se shiftwidth=2
se expandtab
se smarttab
se backspace=indent,eol,start " allow backspacing over everything in insert mode
se scrolloff=6                " keep 4 lines of context when scrolling
set showbreak=↪

" se foldmethod=syntax
" se nofoldenable

se incsearch                  " do incremental search
se hlsearch                   " highlight search results
se noignorecase               " don't ignore case when matching patterns
se smartcase                  " ignores ignorecase when pattern contains uppercase characters

se wildmenu                   " use wild menus
se laststatus=2               " always show the status bar
se number                     " show line numbers
se numberwidth=5
se ruler                      " show line/column number
se showcmd

se winminheight=0
se winheight=999
se fillchars+=vert:           " non breaking space

se noerrorbells
" super slow cursor movement, unfortunately https://github.com/vim/vim/issues/282
" se cursorline
" se linespace=2
" se guifont=Menlo\ for\ Powerline:h14.00

se clipboard=unnamed          " use the OSX clipboard
" se paste

se <BS>=

compiler ruby

au FocusLost * :silent! wa    " autosave on focus lost
au BufWritePre * :%s/\s\+$//e " remove whitespace on save
au WinEnter * wincmd _        " horizontally maximize windows on enter

let mapleader = " "

map <tab> <c-w>w
map <s-tab> <c-w>W

vnoremap p "0dP

" Use ctrl-n to unhighlight search results in normal mode
nmap <silent> <C-N> :silent noh<CR>

