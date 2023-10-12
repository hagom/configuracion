return
-- Fuzzy Finder (files, lsp, etc)
{
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-telescope/telescope-frecency.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-dap.nvim",
        "cljoly/telescope-repo.nvim",
        "nvim-telescope/telescope-media-files.nvim",
        "xiyaowong/telescope-emoji.nvim",
        "jvgrootveld/telescope-zoxide",
        "nvim-telescope/telescope-symbols.nvim",
        "nvim-telescope/telescope-project.nvim",
        "dhruvmanila/telescope-bookmarks.nvim",
        "nvim-telescope/telescope-frecency.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        'nvim-lua/plenary.nvim',
    },
    branch = "master",
    config = function()
        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-u>"] = false,
                        ["<C-d>"] = false,
                    },
                },
            },
        })

        -- require("telescope").load_extension('harpoon')
        require("telescope").load_extension("git_worktree")
        require("telescope").load_extension("refactoring")
        require("telescope").load_extension("project")
        require("telescope").load_extension("bookmarks")
        require("telescope").load_extension("media_files")
        require("telescope").load_extension("luasnip")
        require("telescope").load_extension("dap")
        require("telescope").load_extension("zoxide")
        require("telescope").load_extension("emoji")
        require("telescope").load_extension("file_browser")

        require("telescope").setup({
            defaults = {
                -- Default configuration for telescope goes here:
                -- config_key = value,
                mappings = {
                    i = {
                        -- map actions.which_key to <C-h> (default: <C-/>)
                        -- actions.which_key shows the mappings for your picker,
                        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                        ["<C-h>"] = "which_key",
                    },
                },
            },
            pickers = {
                -- Default configuration for builtin pickers goes here:
                -- picker_name = {
                --   picker_config_key = value,
                --   ...
                -- }
                -- Now the picker_config_key will be applied every time you call this
                -- builtin picker
                -- require'telescope'.extensions.project.project{},
            },
            extensions = {
                -- Your extension configuration goes here:
                -- extension_name = {
                --   extension_config_key = value,
                -- }
                -- please take a look at the readme of the extension you want to configure
                media_files = {
                    -- filetypes whitelist
                    -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
                    filetypes = { "png", "webp", "jpg", "jpeg" },
                    find_cmd = "rg", -- find command (defaults to `fd`)
                },

                bookmarks = {
                    -- Available: 'brave', 'google_chrome', 'safari', 'firefox', 'firefox_dev'
                    selected_browser = "google_chrome",

                    -- Either provide a shell command to open the URL
                    url_open_command = "open",

                    -- Or provide the plugin name which is already installed
                    -- Available: 'vim_external', 'open_browser'
                    url_open_plugin = nil,
                    firefox_profile_name = nil,
                },

                project = {
                    base_dirs = {
                        { "~/Codigo", max_depth = 99 },
                    },
                    hidden_files = true, -- default: false
                },
            },
        })

        -- You don't need to set any of these options.
        -- IMPORTANT!: this is only a showcase of how you can set default options!
        require("telescope").setup {
            extensions = {
                file_browser = {
                    theme = "ivy",
                    -- disables netrw and use telescope-file-browser in its place
                    hijack_netrw = true,
                    mappings = {
                        ["i"] = {
                            -- your custom insert mode mappings
                        },
                        ["n"] = {
                            -- your custom normal mode mappings
                        },
                    },
                },
            },
        }
        -- To get telescope-file-browser loaded and working with telescope,
        -- you need to call load_extension, somewhere after setup function:
        --
        -- Enable telescope fzf native, if installed
        pcall(require("telescope").load_extension, "fzf")

        -- See `:help telescope.builtin`
        vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles,
            { desc = "[?] Find recently opened files" })
        vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers,
            { desc = "[ ] Find existing buffers" })
        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "[/] Fuzzily search in current buffer]" })

        vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
        vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
        vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
        vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })

        -- Diagnostic keymaps
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)


        -- require("telescope-emoji").setup({
        --   action = function(emoji)
        --     -- argument emoji is a table.
        --     -- {name="", value="", cagegory="", description=""}
        --     vim.fn.setreg("*", emoji.value)
        --     print([[Press p or "*p to paste this emoji]] .. emoji.value)
        --   end,
        -- })
        vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope file_browser<CR>",
            { noremap = true, desc = "[F]ile [B]rowser " })
    end,
}
