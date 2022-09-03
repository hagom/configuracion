vim.opt.background     = "dark"
vim.opt.backup         = false
vim.opt.clipboard      = "unnamedplus"
vim.opt.compatible     = false
vim.opt.completeopt    = "menuone,longest,noinsert,noselect"
vim.opt.cursorline     = true
vim.opt.encoding       = "utf-8"
vim.opt.expandtab      = true
vim.opt.foldexpr       = "nvim_treesitter#foldexpr()"
vim.opt.foldmethod     = "expr"
vim.opt.hidden         = true
vim.opt.incsearch      = true
vim.opt.laststatus     = 3
vim.opt.lazyredraw     = true
vim.opt.list           = false
vim.opt.number         = true
vim.opt.omnifunc       = "syntaxcomplete#Complete"
vim.opt.path           = "**"
vim.opt.relativenumber = true
vim.opt.ruler          = true
vim.opt.scrolloff      = 8
vim.opt.shiftwidth     = 4
vim.opt.showmode       = true
vim.opt.signcolumn     = "yes"
vim.opt.smartcase      = true
vim.opt.smartindent    = true
vim.opt.smarttab       = true
vim.opt.spell          = true
vim.opt.spelllang      = "en,es,fr"
vim.opt.spellsuggest   = "best,9"
vim.opt.swapfile       = false
vim.opt.syntax         = "on"
vim.opt.tabstop        = 4
vim.opt.termguicolors  = true
vim.opt.timeout        = false
vim.opt.timeoutlen     = 500
vim.opt.undodir        = "~/.vim/undodir"
vim.opt.undofile       = true
vim.opt.updatetime     = 500
vim.opt.wildignorecase = false
vim.opt.wildmenu       = true
vim.opt.wildmode       = "longest,list,full"
vim.opt.wrap           = false
vim.opt.writebackup    = false
vim.opt.guicursor      = "a:blinkon100"
vim.keymap.set('n','<Leader>e',':NvimTreeToggle<CR>')

vim.cmd([[
	" autocmd filetype plugin indent on
	set mouse=a                                 "Enables mouse
	set shortmess+=c

	"Archivos a ignorar
	set wildignore+=**/.git/*
	set wildignore+=*.pyc
	set wildignore+=*_build/*
	set wildignore+=**/coverage/*
	set wildignore+=**/node_modules/*
	set wildignore+=**/android/*
	set wildignore+=**/ios/*

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

    " Change the colors
    highlight Sneak guifg=black guibg=#00C7DF ctermfg=black ctermbg=cyan
    highlight SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow

    highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#afff5f' gui=underline ctermfg=81 cterm=underline

    let g:qs_max_chars=150

    "Configuración para Coc-yank
    nnoremap <silent> <space>y  :<C-u>CocList -A --normal yank<cr>

    "Configuracion coc-snippets
    " Use <C-l> for trigger snippet expand.
    imap <C-l> <Plug>(coc-snippets-expand)

    " Use <C-j> for select text for visual placeholder of snippet.
    vmap <C-j> <Plug>(coc-snippets-select)

    " Use <C-j> for jump to next placeholder, it's default of coc.nvim
    let g:coc_snippet_next = '<c-j>'

    " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
    let g:coc_snippet_prev = '<c-k>'

    " Use <C-j> for both expand and jump (make expand higher priority.)
    imap <C-j> <Plug>(coc-snippets-expand-jump)

    " Use <leader>x for convert visual selected code to snippet
    xmap <leader>x  <Plug>(coc-convert-snippet)
]])

require("packer-plugins")
