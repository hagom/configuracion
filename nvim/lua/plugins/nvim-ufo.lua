return {
	'kevinhwang91/nvim-ufo',
	dependencies = 'kevinhwang91/promise-async',
	keys = {
		{ "zR", "require('ufo').openAllFolds", desc = "Open all folds" },
		{ "zM", "require('ufo').closeAllFolds", desc = "Close all folds" },
	},
	config = function()
		require('ufo').setup({
			provider_selector = function(bufnr, filetype, buftype)
				return { 'treesitter', 'indent' }
			end
		})
	end
}
