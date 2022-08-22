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

	syntax on                                   "Enalbes sintax highlighting

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

    "Configuración para sneak
    let g:sneak#label = 1

    " case insensitive sneak
    let g:sneak#use_ic_scs = 1

    " immediately move to the next instance of search, if you move the cursor sneak is back to default behavior
    let g:sneak#s_next = 1

    " remap so I can use , and ; with f and t
    map gS <Plug>Sneak_,
    map gs <Plug>Sneak_;

    " Change the colors
    highlight Sneak guifg=black guibg=#00C7DF ctermfg=black ctermbg=cyan
    highlight SneakScope guifg=red guibg=yellow ctermfg=red ctermbg=yellow

    " Cool prompts
    let g:sneak#prompt = '👁️ '
    " let g:sneak#prompt = '🔎'

    " I like quickscope better for this since it keeps me in the scope of a single line
    " map f <Plug>Sneak_f
    " map F <Plug>Sneak_F
    " map t <Plug>Sneak_t
    " map T <Plug>Sneak_T

    "Configuración para quickscope

    "Atajos para activar quickscope
    let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

    highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline
    highlight QuickScopeSecondary guifg='#afff5f' gui=underline ctermfg=81 cterm=underline

    let g:qs_max_chars=150

    "Configuración para Coc-yank
    nnoremap <silent> <space>y  :<C-u>CocList -A --normal yank<cr>

    "Configuración para coc-explorer
    let g:coc_explorer_global_presets = {
    \   '.vim': {
    \     'root-uri': '~/.vim',
    \   },
    \   'tab': {
    \     'position': 'tab',
    \     'quit-on-open': v:true,
    \   },
    \   'floating': {
    \     'position': 'floating',
    \     'open-action-strategy': 'sourceWindow',
    \   },
    \   'floatingTop': {
    \     'position': 'floating',
    \     'floating-position': 'center-top',
    \     'open-action-strategy': 'sourceWindow',
    \   },
    \   'floatingLeftside': {
    \     'position': 'floating',
    \     'floating-position': 'left-center',
    \     'floating-width': 50,
    \     'open-action-strategy': 'sourceWindow',
    \   },
    \   'floatingRightside': {
    \     'position': 'floating',
    \     'floating-position': 'right-center',
    \     'floating-width': 50,
    \     'open-action-strategy': 'sourceWindow',
    \   },
    \   'simplify': {
    \     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
    \   }
    \ }

    " nmap <leader>e :CocCommand explorer<CR>
    " nmap <leader>E :CocCommand explorer --preset floating<CR>
    autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif

    "Configuración LuaSnip
    " press <Tab> to expand or jump in a snippet. These can also be mapped separately
    " via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
    " imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
    " " -1 for jumping backwards.
    " inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>
    "
    " snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
    " snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
    "
    " " For changing choices in choiceNodes (not strictly necessary for a basic setup).
    " imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
    " smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
    
    " Configuracion para Prettier instalado con coc
    command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
]])

require("packer-plugins")
