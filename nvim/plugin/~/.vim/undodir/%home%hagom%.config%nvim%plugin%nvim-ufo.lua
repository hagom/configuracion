Vim�UnDo�  ��WU#�&��'�*݋j�*����B�ڻ                                     bł�    _�                             ����                                                                                                                                                                                                                                                                                                                                                             bł{    �                   �               5��                                          {       5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             bł�     �              5��                                                  5�_�                             ����                                                                                                                                                                                                                                                                                                                                                             bł�    �       	          �             5��                       7                   j      5�_�                           ����                                                                                                                                                                                                                                                                                                                                                             bł�     �             �                vim.o.foldcolumn = '1'   ^vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value   vim.o.foldlevelstart = -1   vim.o.foldenable = true       R-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself   6vim.keymap.set('n', 'zR', require('ufo').openAllFolds)   Mvim.keymap.set('n', 'zM', require('ufo').closeAllFolds)require('ufo').setup({5��                       7                   j      5�_�                            ����                                                                                                                                                                                                                                                                                                                                                             bł�    �                 require("ufo").setup({   .	provider_selector = function(bufnr, filetype)   #		return { "treesitter", "indent" }   	end,   })5��                                  |       s       5��