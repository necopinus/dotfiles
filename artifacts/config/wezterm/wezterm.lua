-- Init boilerplate
--
local wezterm = require "wezterm"
local config = {}

-- OS detection
--
local is_linux <const> = wezterm.target_triple:find("linux") ~= nil
local is_macos <const> = wezterm.target_triple:find("darwin") ~= nil
local is_windows <const> = wezterm.target_triple:find("windows") ~= nil

-- Set font
--
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
if is_macos then
    config.font_size = 12.0
else
    config.font_size = 10.0
end
config.line_height = 1.2

-- Fix color rendering on macOS
--
if is_macos then
    config.front_end = "WebGpu"
end

-- Color scheme
--
config.color_scheme = "GruvboxLightMedium"
config.colors = wezterm.color.load_scheme(
    os.getenv("HOME") .. "/config/wezterm/colors/" .. config.color_scheme .. ".toml"
)
config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 1.0
}

-- Default window setup
--
config.initial_rows = 32
config.initial_cols = 128

config.use_fancy_tab_bar = false
config.tab_max_width = 64
config.default_cursor_style = "BlinkingBar"

if is_macos then
    config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

    config.window_padding = {
        top = "4.5pt",
        right = "8pt",
        bottom = "3pt",
        left = "8pt"
    }
    config.window_frame = {
        border_top_height = "4.5pt",
        border_right_width = 0,
        border_bottom_height = 0,
        border_left_width = 0,

        border_top_color = config.colors.tab_bar.background,
        border_right_color = config.colors.background,
        border_bottom_color = config.colors.background,
        border_left_color = config.colors.background
    }
else
    -- config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

    config.window_padding = {
        top = "6pt",
        right = "6pt",
        bottom = "6pt",
        left = "6pt"
    }

    config.tab_bar_style = {
        window_hide = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_minimize .. " " }
        },
        window_hide_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[4] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_minimize .. " " }
        },
        window_maximize = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_maximize .. " " }
        },
        window_maximize_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[3] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_maximize .. " " }
        },
        window_close = wezterm.format {
            { Foreground = { Color = config.colors.tab_bar.new_tab.fg_color } },
            { Background = { Color = config.colors.tab_bar.new_tab.bg_color } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_close .. " " }
        },
        window_close_hover = wezterm.format {
            { Foreground = { Color = config.colors.ansi[1] } },
            { Background = { Color = config.colors.ansi[2] } },
            { Attribute = { Intensity = "Bold" } },
            { Text = " " .. wezterm.nerdfonts.cod_chrome_close .. " " }
        },
    }
end

-- Launch fish by default (we do this rather than changing the default
-- shell because fish isn't POSIX-compliant and on some systems it's a
-- pain to change the default shell anyways; use a full path here
-- because the macOS GUI doesn't natively know about ~/.nix-profile/bin)
--
config.default_prog = { os.getenv("HOME") .. "/.nix-profile/bin/fish", "-l" }

-- Return config
--
return config
