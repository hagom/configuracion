return {
    "nvim-lualine/lualine.nvim", -- Fancier statusline
    config = function()
        -- Set lualine as statusline
        -- See `:help lualine.txt`
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "onedark",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {},
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = {
                "nvim-tree",
                "symbols-outline",
                "toggleterm",
                "nvim-dap-ui",
            },
        })
    end
}
