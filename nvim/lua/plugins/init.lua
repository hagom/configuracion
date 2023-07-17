return {
	"nvim-orgmode/orgmode", -- Org Mode for neovim
	"onsails/lspkind.nvim",
	"nvim-treesitter/nvim-treesitter-context",

	-- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make",                                cond = vim.fn.executable(
	"make") == 1 },

	{ "ThePrimeagen/harpoon",                     dependencies = { { "nvim-lua/plenary.nvim" } } },
	"akinsho/toggleterm.nvim", -- Floating Terminal

	{
		"folke/which-key.nvim",
	},

	"windwp/nvim-autopairs",                                                   -- Autocompleta los simbolos en el editor
	{ "mfussenegger/nvim-dap", dependencies = { "mfussenegger/nvim-dap-ui" } }, -- Debug Adapter Protocol
	"Vonr/align.nvim",

	{
		"prettier/vim-prettier",
		build = "yarn install --frozen-lockfile --production",
		branch = "master",
	},
}
