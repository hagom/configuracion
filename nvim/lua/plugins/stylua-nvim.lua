return {
    "ckipp01/stylua-nvim",
    build = "cargo install stylua", -- Formateador para Lua
    config = function()
        local lsp_config = require("lspconfig")
        lsp_config.sumneko_lua.setup({
            commands = {
                Format = {
                    function()
                        require("stylua-nvim").format_file()
                    end,
                },
            },
            -- ...
        })
    end
}
