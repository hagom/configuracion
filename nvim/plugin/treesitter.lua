require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		disable = {},
	},
	indent = {
		enable = true,
		disable = {},
	},
	ensure_installed = {
		"tsx",
		"php",
		"json",
		"yaml",
		"python",
		"php",
		"html",
		"scss",
		"css",
		"lua",
		"cpp",
		"c",
		"cpp",
		"javascript",
		"vue",
		"lua",
	},
	autotag = {
		enable = true,
	},
})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsename = { "javascript", "typescript.tsx" }

require("nvim-treesitter.install").prefer_git = true
