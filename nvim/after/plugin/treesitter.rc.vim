if !exists('g:loaded_nvim_treesitter')
    finish
endif

lua << EOF

require 'nvim-treesitter.configs'.setup {
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
  },
  autotag = {
    enable = true
  }
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.used_by = { "javascript", "typescript.tsx" }

EOF
