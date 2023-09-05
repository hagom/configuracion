return
{
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    branch = "master",
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        "williamboman/mason.nvim",
        opts = {
            ensure_installed =
            {
                "lua_ls",
            },
                automatic_installation = true,
        },
        "williamboman/mason-lspconfig.nvim",

        -- ful status updates for LSP
        "j-hui/fidget.nvim",

        -- Additional lua configuration, makes nvim stuff amazing
        "folke/neodev.nvim",
    },
}
