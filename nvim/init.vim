set spellsuggest=best,9                     " Show nine spell checking candidates at most
set spelllang=en,es,fr                      " Usa diccionarios en ingles, espanol y francés
set encoding=utf-8
set showmode
set autoindent
set smartindent                             ""Makes indenting smart
set tabstop=4
set shiftwidth=4
set expandtab smarttab
set nu
set nolist
set rnu
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
filetype plugin indent on
filetype indent on
set omnifunc=syntaxcomplete#Complete
set completeopt=menuone,longest,noinsert,noselect
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
set termguicolors

" Don't redraw while executing macros (good performance config)
set lazyredraw

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

"Iconos para el editor
Plug 'ryanoasis/vim-devicons'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug '~/.fzf'

" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'

"Vim airline
Plug 'vim-airline/vim-airline'

"vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

"Rust
Plug 'rust-lang/rust.vim'

"Esquema de colores gruvbox
Plug 'morhetz/gruvbox'
Plug 'shinchu/lightline-gruvbox.vim'

"Dockerfile.vim
Plug 'ekalinin/Dockerfile.vim'

"Vim undotree
Plug 'mbbill/undotree'

"Colorea los pares de llaves y corchetes
Plug 'junegunn/rainbow_parentheses.vim'

"Typing
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-surround'

"Snippets
Plug 'honza/vim-snippets'

""vim-pandoc
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'

"Emmet
Plug 'mattn/emmet-vim'

"Which Key
Plug 'liuchengxu/vim-which-key'

" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

" To register the descriptions when using the on-demand load feature,
" use the autocmd hook to call which_key#register(), e.g., register for the Space key:
" autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')

"Editorconfig
Plug 'editorconfig/editorconfig-vim' 

"Multiples cursores
Plug 'terryma/vim-multiple-cursors'

Plug 'mhinz/vim-signify'
Plug 'yggdroot/indentline'

"Permite comentar lineas de codigo
Plug 'scrooloose/nerdcommenter'

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }

if has("nvim")
    Plug 'windwp/nvim-ts-autotag'
    "Plugin para iniciar proyectos en nvim en la pantalla de inicio
    Plug 'mhinz/vim-startify'
    "Fuzzy finder para vim
    Plug 'nvim-telescope/telescope.nvim'
    " Use release branch (recommend)
    Plug 'sudormrfbin/cheatsheet.nvim'
    Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
    Plug 'tpope/vim-repeat'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
    Plug 'nvim-treesitter/playground'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lua/popup.nvim'
    "Fuzzy finder para vim
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-media-files.nvim'
    Plug 'xiyaowong/telescope-emoji.nvim'
    Plug 'jvgrootveld/telescope-zoxide'
    Plug 'fannheyward/telescope-coc.nvim'
    Plug 'nvim-telescope/telescope-symbols.nvim'
    Plug 'nvim-telescope/telescope-project.nvim'
    Plug 'dhruvmanila/telescope-bookmarks.nvim'
    Plug 'nvim-telescope/telescope-frecency.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'github/copilot.vim'
    Plug 'ThePrimeagen/git-worktree.nvim'
    Plug 'ThePrimeagen/refactoring.nvim'
    "Frontend para git
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-git'
    Plug 'norcalli/nvim-colorizer.lua'
endif

Plug 'Xuyuanp/nerdtree-git-plugin'

"Resalta los cambios hechos en un archivo en git en la parte izquierda de la ventana
Plug 'airblade/vim-gitgutter'

call plug#end()

"Configuración IndentLine
let g:indentLine_color_term = 255 "Color de la linea de indentacion
let g:indentLine_char = '|' "Caracter de la linea de indentacion

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
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

"Configuración para vim-pandoc-syntax
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

"Configuración para vim-pandoc-syntax para vim-wiki
augroup pandoc_syntax
  autocmd! FileType vimwiki set syntax=markdown.pandoc
augroup END

"Configuración COC

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" Permite renombrar la palabra actual
nmap <F3> <Plug>(coc-rename)

" Remapeo de combinacion de teclas para navegacion usando coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

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

let g:NERDTreeGitStatusUseNerdFonts = 1 " you should install nerdfonts by yourself. default: 0

let g:NERDTreeGitStatusUntrackedFilesMode = 'all' " a heavy feature too. default: normal

let NERDTreeShowHidden=1 "Muestra archivos ocultos en el tree

let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

let g:NERDTreeIgnore = ['^node_modules$']

" Configuración para el autocompletado
let g:completion_matching_stategy_list = ['exact', 'substring', 'fuzzy']

" sync open file with NERDTree
" " Check if NERDTree is open or active
function! IsNERDTreeOpen()        
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufEnter * call SyncTree()

"Configuración para nerdcommenter
vmap ++ <plug>NERDCommenterToggle
nmap ++ <plug>NERDCommenterToggle

"Configuración gitgutter
"Funcion para mosrtar en el statusline si hay cambios en el archivo
function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
set statusline+=%{GitStatus()}

" Configuración para telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>ft <cmd>Telescope tags<cr>
nnoremap <leader>fs <cmd>Telescope git_status<cr>
nnoremap <leader>fc <cmd>Telescope command_history<cr>

"Configuración para emmet
let g:user_emmet_mode='a'    "enable all function in all mode.
let g:user_emmet_settings = {
\  'variables': {'lang': 'es'},
\  'html': {
\    'default_attributes': {
\      'option': {'value': v:null},
\      'textarea': {'id': v:null, 'name': v:null, 'cols': 10, 'rows': 10},
\    },
\    'snippets': {
\      'html:5': "<!DOCTYPE html>\n"
\              ."<html lang=\"${lang}\">\n"
\              ."<head>\n"
\              ."\t<meta charset=\"${charset}\">\n"
\              ."\t<title></title>\n"
\              ."\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
\              ."</head>\n"
\              ."<body>\n\t${child}|\n</body>\n"
\              ."</html>",
\    },
\  },
\}

"Configuración para el diccionario del editor
nnoremap <silent> <F11> :set spell!<cr>
inoremap <silent> <F11> <C-O>:set spell!<cr>

lua require'plug-colorizer'

"Configuración para rainbow indent
let g:rainbow#max_level = 16
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

autocmd FileType * RainbowParentheses

"Configuración para startify
let g:startify_session_dir = '~/.config/nvim/session'

let g:startify_lists = [
          \ { 'type': 'files',     'header': ['   Archivos']            },
          \ { 'type': 'dir',       'header': ['   Directorio actual  '. getcwd()] },
          \ { 'type': 'sessions',  'header': ['   Sesiones']       },
          \ { 'type': 'bookmarks', 'header': ['   Marcadores']      },
          \ ]

let g:startify_bookmarks = [
            \ '~/Codigo',
            \ ]

let g:startify_session_autoload = 1
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1
let g:startify_enable_special = 0

