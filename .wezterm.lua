-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

-- config.font = wezterm.font 'Fira Code'
-- You can specify some parameters to influence the font selection;
-- for example, this selects a Bold, Italic font variant.
-- config.font =
--   wezterm.font('JetBrains Mono')

-- and finally, return the configuration to wezterm
    config.window_decorations = 'RESIZE'
    config.tab_bar_at_bottom = true
    config.use_fancy_tab_bar = false
    config.hide_tab_bar_if_only_one_tab = true
return config

