return {
	'tzachar/cmp-tabnine',
	build = './install.sh',
	dependencies = 'hrsh7th/nvim-cmp',
	config = function()
		local prefetch = vim.api.nvim_create_augroup("prefetch", { clear = true })

		vim.api.nvim_create_autocmd('BufRead', {
			group = prefetch,
			pattern = '*.py',
			callback = function()
				require('cmp_tabnine'):prefetch(vim.fn.expand('%:p'))
			end
		})
	end
}
