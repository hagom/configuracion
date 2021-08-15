set encoding=utf-8
set showmode
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab smarttab
set nu
set nolist
set rnu
set smartindent                             ""Makes indenting smart
set smartcase
set noswapfile
set incsearch
set background=dark
set hidden
set nowrap
set swapfile
set cursorline                              ""Enable highlighting of the current line
set nobackup
set nowritebackup
set undodir=~/.vim/undodir
set undofile
set scrolloff=8
set signcolumn=yes
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete
set completeopt=menuone,longest
set mouse=a                                 ""Enables mouse
set wildmenu
set wildmode=longest,list,full
set nocompatible
set path+=**
set wildmode=longest:full,full
set wildignorecase
set wildignore=\*.git/\*
set clipboard=unnamedplus                   ""Enables clipboard to copy and paste
set shortmess+=c

"Archivos a ignorar
set wildignore+=**/.git/*
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set updatetime=300                          ""Faster completion
set notimeout
set ruler

syntax on                                   ""Enalbes sintax highlighting

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
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'

" Initialize plugin system

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}

"Vim airline
Plug 'vim-airline/vim-airline'

"vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

"Vimagit
Plug 'jreybert/vimagit'

"Rust
Plug 'rust-lang/rust.vim'

"ALE (ASYNCHRONOUS LINT ENGINE) 
Plug 'w0rp/ale'

"Esquema de colores gruvbox
Plug 'morhetz/gruvbox'

"Dockerfile.vim
Plug 'ekalinin/Dockerfile.vim'

"Vim undotree
Plug 'mbbill/undotree'

"RAINBOW PARENTHESES IMPROVED
Plug 'luochen1990/rainbow'

"Autopairs
Plug 'jiangmiao/auto-pairs'

"Snippets
Plug 'honza/vim-snippets'


"vim-pandoc
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

"Emmet
Plug 'emmetio/emmet'

"Tabnine
Plug 'codota/tabnine-vim'

"Which Key
Plug 'liuchengxu/vim-which-key'

" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

" To register the descriptions when using the on-demand load feature,
" use the autocmd hook to call which_key#register(), e.g., register for the Space key:
" autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')

call plug#end()

"Mapear para NERDTree
map <F2> :NERDTreeToggle<CR>

"Mapear Undotree
nnoremap <F5> :UndotreeToggle<CR>

"Configuración para Undotree
if has("persistent_undo")
   let target_path = expand('~/.undodir')

    " create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif

    let &undodir=target_path
    set undofile
endif

"Configuración vim-snippets"

let g:snipMate = {}

"Configuracion para Rust
let g:rust_clip_command = 'xclip -selection clipboard'
let g:rustfmt_autosave = 1

"Configuracion para gruvbox
autocmd vimenter * ++nested colorscheme gruvbox

"Configuración RAINBOW IMPROVED
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

"Configuración Autopairs
let g:AutoPairsFlyMode = 1
let g:AutoPairsShortcutBackInsert = '<M-b>'

"Configuración para vim-pandoc-syntax
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

"Configuración para vim-pandoc-syntax para vim-wiki
augroup pandoc_syntax
  autocmd! FileType vimwiki set syntax=markdown.pandoc
augroup END

