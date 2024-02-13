return {
	"uga-rosa/cmp-dictionary",
	config = function()
		require("cmp_dictionary").setup({
			paths = {
				"/usr/share/dict/words",
				"/usr/share/dict/spanish"
			},
			exact_length = 2,
			first_case_insensitive = true,
			document = {
				enable = true,
				command = { "wn", "${label}", "-over" },
			}
		})
	end
}
