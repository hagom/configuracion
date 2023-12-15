return {
  "nvim-tree/nvim-web-devicons",
  branch = "master",
  -- tag = "nerd-v2-compat",
  lazy = true,
  config = function()
    -- require'nvim-web-devicons'.has_loaded()
    require 'nvim-web-devicons'.get_icons()
  end
}
