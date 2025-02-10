return {
	"ggandor/leap.nvim",
	-- lazy = true,
	enabled = false,
	config = function ()
		require('leap').add_default_mappings()
	end
}
