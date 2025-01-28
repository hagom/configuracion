return
{
	'echasnovski/mini.nvim',
	version = '*',
	config = function()
		-- require('mini.diff').setup()
		require('mini.align').setup()
		require('mini.animate').setup()
		require('mini.bracketed').setup()
		require('mini.comment').setup()
		require('mini.icons').setup()
		require('mini.pairs').setup()
		require('mini.cursorword').setup()
		require('mini.surround').setup()
		MiniIcons.mock_nvim_web_devicons()
	end,
}
