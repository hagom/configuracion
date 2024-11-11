return
{
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-emoji",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "dcampos/cmp-emmet-vim",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        "lukas-reineke/cmp-rg",
        "uga-rosa/cmp-dictionary",
        "kkharji/sqlite.lua",
        -- "fazibear/cmp-nerdfonts",
        {
            "David-Kunz/cmp-npm",
            dependencies = { 'nvim-lua/plenary.nvim' },
            ft = "json",
            config = function()
                require('cmp-npm').setup({})
            end
        },
        {
            "roobert/tailwindcss-colorizer-cmp.nvim",
            -- optionally, override the default options:
            config = function()
                require("tailwindcss-colorizer-cmp").setup({
                    color_square_width = 2,
                })
            end
        },
    },
    event = "VeryLazy",
    config = function()
        -- Set up nvim-cmp.
        -- require('cmp_nerdfonts').update()
        local cmp = require 'cmp'
        local lspkind = require('lspkind')
        local luasnip = require('luasnip')
        local source_mapping = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            cmp_tabnine = "[TN]",
            path = "[Path]",
            codeium = "[Codeium]",
            cody = "[Cody]",
        }

        local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local dict = require("cmp_dictionary")

        -- dict.switcher({
        --     filetype = {
        --         lua = "/path/to/lua.dict",
        --         javascript = { "/path/to/js.dict", "/path/to/js2.dict" },
        --     },
        --     filepath = {
        --         [".*xmake.lua"] = { "/path/to/xmake.dict", "/path/to/lua.dict" },
        --         ["%.tmux.*%.conf"] = { "/path/to/js.dict", "/path/to/js2.dict" },
        --     },
        --     spelllang = {
        --         en = "/path/to/english.dict",
        --     },
        -- })

        cmp.setup({
            formatting = {
                format = lspkind.cmp_format({
                    require("tailwindcss-colorizer-cmp").formatter,
                    mode = 'symbol',       -- show only symbol annotations
                    maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                    ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

                    -- The function below will be called before any actual modifications from lspkind
                    -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                    before = function(entry, vim_item)
                        return vim_item
                    end
                })
            },
            formatting = {
                format = require('lspkind').cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    ellipsis_char = '...',
                    symbol_map = { Codeium = "", }
                })
            },

            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end,
            },
            window = {
                -- completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
            },

            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                        -- they way you will only jump inside the snippet region
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),

            sources = cmp.config.sources({
                { name = 'orgmode' },
                { name = 'codeium' },
                { name = 'cody' },
                { name = 'nerdfonts' },
                { name = 'npm',      keyword_length = 4 },
                { name = "rg" },
                { name = 'emmet_vim' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lua' },
                { name = 'emoji' },
                -- { name = 'cmp_tabnine' },
                { name = 'luasnip' }, -- For luasnip users.
                -- { name = 'vsnip' }, -- For vsnip users.
                -- { name = 'ultisnips' }, -- For ultisnips users.
                -- { name = 'snippy' }, -- For snippy users.
            }, {
                { name = 'buffer' },
                {
                    name = "dictionary",
                    keyword_length = 2,
                },
            })
        })

        -- Set configuration for specific filetype.
        cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
                { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
                { name = 'buffer' },
            })
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' },
                { name = 'nvim_lsp_document_symbol' }
            }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- Set up lspconfig.
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
        -- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
        --     capabilities = capabilities
        -- }

        require('lspconfig')['rust_analyzer'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['bashls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['clangd'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['jsonls'].setup {
            capabilities = capabilities
        }

        -- require('lspconfig')['pyright'].setup {
        --     capabilities = capabilities
        -- }

        require('lspconfig')['vuels'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['html'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['cssls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['emmet_ls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['yamlls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['tailwindcss'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['dockerls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['gopls'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['phpactor'].setup {
            capabilities = capabilities
        }

        require('lspconfig')['ruff'].setup {
            capabilities = capabilities
        }
    end
}
