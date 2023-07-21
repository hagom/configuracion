return
{
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = function()
        pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
    config = function()
        require 'nvim-treesitter.configs'.setup {
            ensure_installed = { "c", "bash", "c_sharp", "css", "cpp", "dockerfile", "dot", "git_config", "git_rebase",
                "gitattributes", "gitcommit", "gitignore", "go", "graphql", "html", "htmldjango", "http", "java",
                "javascript", "jq", "jsdoc", "json", "lua", "luadoc", "markdown", "php", "phpdoc", "python", "rust",
                "scss", "sql", "terraform", "tsx", "vue", "yaml" },
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            highlight = {
                enable = true,
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = false,
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
        }
    end
}
