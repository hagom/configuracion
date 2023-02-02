require("telescope").load_extension("git_worktree")
require("telescope").load_extension("harpoon")
require("telescope").load_extension("refactoring")
require("telescope").load_extension("project")
require("telescope").load_extension("bookmarks")
require("telescope").load_extension("coc")
require("telescope").load_extension("media_files")
-- require("telescope").load_extension("luasnip")
require("telescope").load_extension("zoxide")
require("telescope").load_extension("emoji")

require("telescope").setup({
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		mappings = {
			i = {
				-- map actions.which_key to <C-h> (default: <C-/>)
				-- actions.which_key shows the mappings for your picker,
				-- e.g. git_{create, delete, ...}_branch for the git_branches picker
				["<C-h>"] = "which_key",
			},
		},
	},
	pickers = {
		-- Default configuration for builtin pickers goes here:
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
		-- require'telescope'.extensions.project.project{},
	},
	extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
		media_files = {
			-- filetypes whitelist
			-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
			filetypes = { "png", "webp", "jpg", "jpeg" },
			find_cmd = "rg", -- find command (defaults to `fd`)
		},

		bookmarks = {
			-- Available: 'brave', 'google_chrome', 'safari', 'firefox', 'firefox_dev'
			selected_browser = "google_chrome",

			-- Either provide a shell command to open the URL
			url_open_command = "open",

			-- Or provide the plugin name which is already installed
			-- Available: 'vim_external', 'open_browser'
			url_open_plugin = nil,
			firefox_profile_name = nil,
		},

		project = {
			base_dirs = {
				{ "~/Codigo", max_depth = 99 },
			},
			hidden_files = true, -- default: false
		},
	},
})

-- require("telescope-emoji").setup({
--   action = function(emoji)
--     -- argument emoji is a table.
--     -- {name="", value="", cagegory="", description=""}
--     vim.fn.setreg("*", emoji.value)
--     print([[Press p or "*p to paste this emoji]] .. emoji.value)
--   end,
-- })

