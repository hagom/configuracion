set encoding=utf-8
set showmode
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set nu
set nolist
set rnu
set smartindent
set smartcase
set noswapfile
set incsearch
set background=dark
set hidden
set nowrap
set swapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set scrolloff=8
set signcolumn=yes
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete
set mouse=a
set clipboard=unnamedplus

syntax on

call plug#begin('~/.vim/plugged')

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'

" Initialize plugin system

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Vim airline
Plug 'vim-airline/vim-airline'

call plug#end()

"Mapear para NERDTree
map <F2> :NERDTreeToggle<CR>

