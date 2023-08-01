return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    "leoluz/nvim-dap-go",
    "mxsdev/nvim-dap-vscode-js",
    -- "anuvyklack/hydra.nvim",
    "nvim-telescope/telescope-dap.nvim",
    "rcarriga/cmp-dap",
  },
  branch = "master",
  keys = { { "<leader>d", desc = "Open Debug menu" } },
}
