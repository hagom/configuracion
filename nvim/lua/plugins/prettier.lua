return {
  "prettier/vim-prettier",
  keys = {
    { "<leader>p<cr>", "<cmd>PrettierAsync<cr>", desc = "Prettier formatting" },
  },
  enabled = true,
  build = "yarn install --frozen-lockfile --production",
  branch = "master",
}
