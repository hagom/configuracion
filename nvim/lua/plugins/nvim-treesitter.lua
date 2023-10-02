return
{
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "HiPhish/nvim-ts-rainbow2",
    },
    build = ":TSUpdate",
    config = function()
        require 'nvim-treesitter.configs'.setup {
            ensure_installed = { "c", "bash", "c_sharp", "css", "cpp", "dockerfile", "dot", "git_config", "git_rebase",
                "gitattributes", "gitcommit", "gitignore", "go", "graphql", "html", "htmldjango", "http", "java",
                "javascript", "jq", "jsdoc", "json", "lua", "luadoc", "markdown", "php", "phpdoc", "python", "rust",
                "scss", "sql", "terraform", "tsx", "vue", "yaml" },
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- context_commentstring = {
            --     enable = true,
            -- },
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            highlight = {
                enable = true,
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "gnn", -- set to `false` to disable one of the mappings
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                },
            },
            indent = {
                enable = true
            },
            autotag = {
                enable = true,
                enable_rename = true,
                enable_close = true,
                enable_close_on_slash = true,
                -- filetypes = { "html", "xml", "jsx","js","ts","tsx" },
            },
            rainbow = {
                enable = true,
                -- list of languages you want to disable the plugin for
                disable = { 'jsx', 'cpp' },
                -- Which query to use for finding delimiters
                query = 'rainbow-parens',
                -- Highlight the entire buffer all at once
                strategy = require('ts-rainbow').strategy.global,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@conditional.outer",
                        ["ic"] = "@conditional.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                    }
                }
            }
        }
    end
}
