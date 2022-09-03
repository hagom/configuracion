local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

return require("packer").startup(function()
	-- A partir de aca se colocan los plugins

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end --packer se puede administrar a si mismo

	use("windwp/nvim-ts-autotag")
	use("wbthomason/packer.nvim") -- Manejador de plugins para Neovim
	use("gruvbox-community/gruvbox") -- Tema para el editor
	use("ryanoasis/vim-devicons")
	use("windwp/nvim-autopairs") -- Autocompleta los simbolos en el editor
	use({ "L3MON4D3/LuaSnip" }) -- Snippets
	use("rafamadriz/friendly-snippets") --Snippets para LuaSnip
	use({ "mfussenegger/nvim-dap", requires = { "mfussenegger/nvim-dap-ui" } }) -- Debug Adapter Protocol
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icons
		},
		tag = "nightly", -- optional, updated every week. (see issue #1193)
	})

	use("Vonr/align.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
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
			{ "benfowler/telescope-luasnip.nvim" },
		},
	})
	use("tpope/vim-surround")
	use("neovim/nvim-lspconfig") -- Configurations for Nvim LSP
	use({ "ckipp01/stylua-nvim", run = "cargo install stylua" }) -- Formateador para Lua

	use({
		"williamboman/nvim-lsp-installer",
	})

	use({ "neoclide/coc.nvim", branch = "master", run = "yarn install --frozen-lockfile" })

	use({
		"folke/which-key.nvim",
	})

	use({ "ThePrimeagen/harpoon", requires = { { "nvim-lua/plenary.nvim" } } })

	use("akinsho/toggleterm.nvim")

	use({
		"sudormrfbin/cheatsheet.nvim",

		requires = {
			{ "nvim-telescope/telescope.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },
		},
	})
	use("sunjon/shade.nvim")
	use("tpope/vim-repeat")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("saadparwaiz1/cmp_luasnip")
	use({ "tzachar/cmp-tabnine", run = "./install.sh", requires = "hrsh7th/nvim-cmp" })
	use("mhinz/vim-startify")
	-- use("justinmk/vim-sneak") -- Plugin para mejorar el movimiento dentro de neovim
	-- use("unblevable/quick-scope") -- Plugin para mejorar el movimiento horizontal
	use("ggandor/lightspeed.nvim") -- Mejora el movimiento dentro del editor
	use("mattn/emmet-vim")
	use("alvan/vim-closetag")
	use("mbbill/undotree") -- Muestra un arbol de cambios en el editor
	use("editorconfig/editorconfig-vim")
	use("lukas-reineke/indent-blankline.nvim")

	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" }) -- Manejador de repositorios en GIT
	use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" }) -- Permite ver las diferencias entre las modificaciones realizadas a un archivo
	use("norcalli/nvim-colorizer.lua")
	use({
		"ThePrimeagen/refactoring.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
			{ "ThePrimeagen/git-worktree.nvim" },
		},
	})
	use("numToStr/Comment.nvim")
	use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" }) -- Permite hacer pliegues en el codigo

	use("nvim-orgmode/orgmode")
	use({
		"lewis6991/gitsigns.nvim",
		-- tag = 'release' -- To use the latest release
	})

	use("p00f/nvim-ts-rainbow")
	use("onsails/lspkind.nvim")

	use({
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	})

	use("kyazdani42/nvim-web-devicons")

	use("RishabhRD/popfix")
	use("RishabhRD/nvim-lsputils")
end)
