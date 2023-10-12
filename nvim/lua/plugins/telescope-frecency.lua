return {
	"nvim-telescope/telescope-frecency.nvim",
	keys = {
		{ "<leader>tf", "<cmd>Telescope frecency<cr>", desc = "Telescope Frecency" },
	},
	config = function()
		require("telescope").load_extension "frecency"
	end,
}
