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
    "vue",
  },
  autotag = {
    enable = true,
  }
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.used_by = { "javascript", "typescript.tsx" }

require("nvim-treesitter.install").prefer_git = true
