return {
  "folke/persistence.nvim",
  config = function()
    -- restore the session for the current directory
    vim.api.nvim_set_keymap("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], {desc = "restore the session for the current directory"})

    -- restore the last session
    vim.api.nvim_set_keymap("n", "<leader>ql", [[<cmd>lua require("persistence").load({ last = true })<cr>]], {desc = "restore the session for the current directory"})

    -- stop Persistence => session won't be saved on exit
    vim.api.nvim_set_keymap("n", "<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]], {desc = "restore the session for the current directory"})
  end
}
