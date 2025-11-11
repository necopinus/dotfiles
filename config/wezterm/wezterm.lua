-- Init boilerplate
--
local wezterm = require 'wezterm'
local config = {}

-- Set font
--
config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
config.font_size = 10.0

-- Color scheme
--
config.color_scheme = 'Gruvbox light, medium (base16)'

-- Return config
--
return config
