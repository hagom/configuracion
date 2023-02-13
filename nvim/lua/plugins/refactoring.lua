return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-treesitter/nvim-treesitter" },
        { "ThePrimeagen/git-worktree.nvim" },
    },
    config = function()
      local refactor = require("refactoring")
      refactor.setup({
          -- prompt for return type
          prompt_func_return_type = {
              go = true,
              cpp = true,
              c = true,
              java = true,
          },
          -- prompt for function parameters
          prompt_func_param_type = {
              go = true,
              cpp = true,
              c = true,
              java = true,
          },
      })

      -- load refactoring Telescope extension
      require("telescope").load_extension("refactoring")

      -- telescope refactoring helper
      local function refactor(prompt_bufnr)
        local content = require("telescope.actions.state").get_selected_entry(
                prompt_bufnr
            )
        require("telescope.actions").close(prompt_bufnr)
        require("refactoring").refactor(content.value)
      end
      -- NOTE: M is a global object
      -- for the sake of simplicity in this example
      -- you can extract this function and the helper above
      -- and then require the file and call the extracted function
      -- in the mappings below
      M = {}
      M.refactors = function()
        local opts = require("telescope.themes").get_cursor() -- set personal telescope options
        require("telescope.pickers").new(opts, {
            prompt_title = "refactors",
            finder = require("telescope.finders").new_table({
                results = require("refactoring").get_refactors(),
            }),
            sorter = require("telescope.config").values.generic_sorter(opts),
            attach_mappings = function(_, map)
              map("i", "<CR>", refactor)
              map("n", "<CR>", refactor)
              return true
            end
        }):find()
      end

      vim.api.nvim_set_keymap("v", "<Leader>re",
          [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
          { noremap = true, silent = true, expr = false })
      vim.api.nvim_set_keymap("v", "<Leader>rf",
          [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
          { noremap = true, silent = true, expr = false })
      vim.api.nvim_set_keymap("v", "<Leader>rt", [[ <Esc><Cmd>lua M.refactors()<CR>]],
          { noremap = true, silent = true, expr = false })
      vim.api.nvim_set_keymap("v", "<Leader>ri",
          [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
          { noremap = true, silent = true, expr = false })
      vim.api.nvim_set_keymap("n", "<Leader>ri",
          [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
          { noremap = true, silent = true, expr = false })
      --
      -- remap to open the Telescope refactoring menu in visual mode
      vim.api.nvim_set_keymap(
          "v",
          "<leader>rr",
          "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
          { noremap = true }
      )
    end
}
