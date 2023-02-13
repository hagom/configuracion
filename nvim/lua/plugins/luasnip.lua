return {
    "rafamadriz/friendly-snippets",
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load() -- Para cargar snippet
        require 'luasnip'.filetype_extend("ruby", { "rails" })
        require 'luasnip'.filetype_extend("python", { "django" })
        require 'luasnip'.filetype_extend("php", { "laravel" })
    end,
}
