return {
  "nvim-tree/nvim-web-devicons",
  -- tag = "nerd-v2-compat",
  lazy = true,
  config = function()
    require 'nvim-web-devicons'.get_icons()
  end
}
