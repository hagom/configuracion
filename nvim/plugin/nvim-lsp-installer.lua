require("nvim-lsp-installer").setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    check_outdated_servers_on_open = true,  -- Chequea paquetes desactualizados
    max_concurrent_installers = 4,
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    },

    ensure_installed = {
    "bashls",
    "clangd",
    "dockerls",
    "emmet_ls",
    "html",
    "intelephense",
    "jsonls",
    "lemminx",
    "omnisharp",
    "puppet",
    "pyls",
    "pyright",
    "pyright",
    "remark_ls",
    "rust_analyzer",
    "sqlls",
    "sumneko_lua",
    "tailwindcss",
    "terraformls",
    "tsserver",
    "vimls",
    "volar",
    "yamlls",
    }, -- servers to install
})

