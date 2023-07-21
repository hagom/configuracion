return {
	"nvim-orgmode/orgmode", -- Org Mode for neovim
	"onsails/lspkind.nvim",

	-- Fuzzy Finder Algorithm which dependencies local dependencies to be built. Only load if `make` is available
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make",                                cond = vim.fn.executable(
	"make") == 1 },

	{
		"folke/which-key.nvim",
	},

	"windwp/nvim-autopairs",                                                   -- Autocompleta los simbolos en el editor
	"Vonr/align.nvim",

	{
		"prettier/vim-prettier",
		build = "yarn install --frozen-lockfile --production",
		branch = "master",
	},
}
