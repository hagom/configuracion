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
<<<<<<< HEAD
filetype plugin on
=======
filetype plugin indent on
>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51
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

<<<<<<< HEAD
" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
=======
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug '~/.fzf'
>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51

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

<<<<<<< HEAD
"ALE (ASYNCHRONOUS LINT ENGINE) 
Plug 'w0rp/ale'

"Esquema de colores gruvbox
Plug 'morhetz/gruvbox'
=======
"Esquema de colores gruvbox
Plug 'morhetz/gruvbox'
Plug 'shinchu/lightline-gruvbox.vim'
>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51

"Dockerfile.vim
Plug 'ekalinin/Dockerfile.vim'

"Vim undotree
Plug 'mbbill/undotree'

"RAINBOW PARENTHESES IMPROVED
Plug 'luochen1990/rainbow'

"Autopairs
Plug 'jiangmiao/auto-pairs'

<<<<<<< HEAD
"Snippets
Plug 'honza/vim-snippets'


=======
"Typing
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-surround'

"Snippets
Plug 'honza/vim-snippets'

>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51
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

<<<<<<< HEAD
=======
"Syntastic syntax checker
Plug 'vim-syntastic/syntastic'

"Editorconfig
Plug 'editorconfig/editorconfig-vim' 

"Multiples cursores
Plug 'terryma/vim-multiple-cursors'

Plug 'easymotion/vim-easymotion'
Plug 'mhinz/vim-signify'
Plug 'yggdroot/indentline'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-repeat'

>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51
call plug#end()

"Mapear para NERDTree
map <F2> :NERDTreeToggle<CR>

<<<<<<< HEAD
=======
"Configuración adicional de NERDTree
let g:NERDTreeIgnore = ['^node_modules$']

>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51
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

<<<<<<< HEAD
=======
"Configuración COC
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ ]
" use <tab> for trigger completion and navigate to the next complete item
" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

"Fin de la configuración de COC


"Syntastic configuración

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1
>>>>>>> 11d84e600d28cf3186e3661bcecef1ec20b32e51
