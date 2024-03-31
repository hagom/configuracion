return {
  "akinsho/toggleterm.nvim",
  config = function()
    local status_ok, toggleterm = pcall(require, "toggleterm")
    if not status_ok then
      return
    end

    toggleterm.setup({
      size = 13,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float", -- Esta es la opción a cambiar en caso de querer la terminal en otra dirección
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })
  end
}
