-- Install Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "windwp/nvim-ts-autotag" },

	{ "tpope/vim-surround" }, -- Change symbols

    { -- LSP Configuration & Plugins
      "neovim/nvim-lspconfig",
      dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",

        -- ful status updates for LSP
        "j-hui/fidget.nvim",

        -- Additional lua configuration, makes nvim stuff amazing
        "folke/neodev.nvim",
      },
    },

    { -- Autocompletion
      "hrsh7th/nvim-cmp",
      dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline"},
    },

	-- Snippets
	{ "rafamadriz/friendly-snippets" },
	-- { "L3MON4D3/LuaSnip", version = "master" },

  -- {
  --   "L3MON4D3/LuaSnip",
  --   -- follow latest release.
  --   version = "master",
  --   -- install jsregexp (optional!).
  --   build = "make install_jsregexp"
  -- },

    { -- Highlight, edit, and navigate code
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      build = function()
        pcall(require("nvim-treesitter.install").update({ with_sync = true }))
      end,
    },

	-- Git related plugins
	--  'tpope/vim-fugitive'
	"tpope/vim-rhubarb",
	"lewis6991/gitsigns.nvim",

	"navarasu/onedark.nvim", -- Theme inspired by Atom
	"nvim-lualine/lualine.nvim", -- Fancier statusline
	"lukas-reineke/indent-blankline.nvim", -- Add indentation guides even on blank lines
	"numToStr/Comment.nvim", -- "gc" to comment visual regions/lines
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	-- Fuzzy Finder (files, lsp, etc)
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-dap.nvim" },
      { "cljoly/telescope-repo.nvim" },
      { "nvim-telescope/telescope-media-files.nvim" },
      { "xiyaowong/telescope-emoji.nvim" },
      { "jvgrootveld/telescope-zoxide" },
      { "fannheyward/telescope-coc.nvim" },
      { "nvim-telescope/telescope-symbols.nvim" },
      { "nvim-telescope/telescope-project.nvim" },
      { "dhruvmanila/telescope-bookmarks.nvim" },
      { "nvim-telescope/telescope-frecency.nvim" },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },

	-- ("mhinz/vim-startify") -- Shows a welcome screen
    {
      "goolord/alpha-nvim",
      -- dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("alpha").setup(require("alpha.themes.startify").config)
      end,
    },

	{ "tzachar/cmp-tabnine", build = "./install.sh", dependencies = "hrsh7th/nvim-cmp" }, -- Autocomplete
	"ggandor/lightspeed.nvim", -- Mejora el movimiento dentro del editor
	{ "ckipp01/stylua-nvim", build = "cargo install stylua" }, -- Formateador para Lua
	"mattn/emmet-vim",
	"alvan/vim-closetag", -- Autoclose tag
	"mbbill/undotree", -- Muestra un arbol de cambios en el editor
	"editorconfig/editorconfig-vim",

    {
      "ThePrimeagen/refactoring.nvim",
      dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        { "ThePrimeagen/git-worktree.nvim" },
      },
    },

	"nvim-orgmode/orgmode", -- Org Mode for neovim
	"onsails/lspkind.nvim",
	"nvim-treesitter/nvim-treesitter-context",
	{ "TimUntersberger/neogit", dependencies = "nvim-lua/plenary.nvim" }, -- Manejador de repositorios en GIT

	-- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },

	{ "ThePrimeagen/harpoon", dependencies = { { "nvim-lua/plenary.nvim" } } },
	"akinsho/toggleterm.nvim", -- Floating Terminal

    {
      "folke/which-key.nvim",
    },

	"windwp/nvim-autopairs", -- Autocompleta los simbolos en el editor
	{ "mfussenegger/nvim-dap", dependencies = { "mfussenegger/nvim-dap-ui" } }, -- Debug Adapter Protocol
	"Vonr/align.nvim",

  {
  "prettier/vim-prettier",
    build = "yarn install --frozen-lockfile --production",
    branch = "master",
  },

    {
      "kyazdani42/nvim-tree.lua",
      dependencies = {
        "kyazdani42/nvim-web-devicons", -- optional, for file icons
      },
      tag = "nightly", -- optional, updated every week. (see issue #1193)
  },
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Cursor
vim.o.guicursor = "a:blinkon100"

vim.o.spell = true -- Enables the dictionary
vim.o.spelllang = "es,en" --Dictionaries
vim.o.spellsuggest = "best,9" --Dictionaries

vim.opt.scrolloff = 8

-- vim.cmd(
--   [[
--    let g:startify
--
--   ]]
-- )

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Global Status Line
vim.o.laststatus = 3

-- Options for indentation
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Make line numbers default
vim.wo.rnu = true
vim.wo.number = true

-- Make System clipboard available
vim.o.clipboard = "unnamedplus"

-- Enable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd([[colorscheme onedark]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Keymap for moving lines
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- Set lualine as statusline
-- See `:help lualine.txt`
require("lualine").setup({
	options = {
		icons_enabled = false,
		theme = "onedark",
		component_separators = "|",
		section_separators = "",
	},
})

-- Enable Comment.nvim
require("Comment").setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require("indent_blankline").setup({
	char = "┊",
	show_trailing_blankline_indent = false,
})

-- Gitsigns
-- See `:help gitsigns.txt`
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
				["<C-d>"] = false,
			},
		},
	},
})

-- Enable telescope fzf native, if installed
pcall(require("telescope").load_extension, "fzf")

-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer]" })

vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	-- NOTE: Remember that lua is a real programming language, and as such it is possible
	-- to define small helper and utility functions so you don't have to repeat yourself
	-- many times.
	--
	-- In this case, we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	-- See `:help K` for why this keymap
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	-- Lesser used LSP functionality
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format()
	end, { desc = "Format current buffer with LSP" })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
	clangd = {},
	gopls = {},
	pyright = {},
	rust_analyzer = {},
	tsserver = {},

	sumneko_lua = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

-- Setup neovim lua configuration
require("neodev").setup()
--
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require("mason").setup()

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
		})
	end,
})

-- Turn on lsp status information
require("fidget").setup()

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
