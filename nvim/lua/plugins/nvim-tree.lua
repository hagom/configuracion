return {
    "kyazdani42/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    dependencies = {
        "kyazdani42/nvim-web-devicons", -- optional, for file icons
    },
    tag = "nightly", -- optional, updated every week. (see issue #1193)
    keys = { "<leader>e", desc = "NvimTree" },
    config = function()
        require("nvim-tree").setup({
            sort_by = "case_sensitive",
            view = {
                relativenumber = true,
                number = true,
                adaptive_size = true,
                mappings = {
                    list = {
                        { key = "u", action = "dir_up" },
                    },
                },
            },
            renderer = {
                group_empty = true,
                highlight_opened_files = "yes",
                highlight_modified = "yes",
                indent_markers = {
                    enable = true,
                    inline_arrows = true,
                    icons = {
                        corner = "└",
                        edge = "│",
                        item = "│",
                        bottom = "─",
                        none = " ",
                    },
                },
            },
            filters = {
                dotfiles = true,
            },
            modified = {
                enable = true,
                show_on_dirs = true,
                show_on_open_dirs = true,
            },
        })
        -- disable netrw at the very start of your init.lua (strongly advised)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- set termguicolors to enable highlight groups
        vim.opt.termguicolors = true
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {desc = "NvimTreeToggle"})
    end
}
