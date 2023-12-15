return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    "rcarriga/nvim-dap-ui",
    opts = 
    {
      event = "VeryLazy",
    },
    "leoluz/nvim-dap-go",
    "mxsdev/nvim-dap-vscode-js",
    -- "anuvyklack/hydra.nvim",
    "nvim-telescope/telescope-dap.nvim",
    "rcarriga/cmp-dap",
  },
  branch = "master",
  keys = { { "<leader>db", desc = "Open Debug menu" } },
}
