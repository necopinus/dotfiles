---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local gears = require("gears")
local wibox = require("wibox")

local dpi = xresources.apply_dpi
local themes_path = gears.filesystem.get_configuration_dir()

local nerd_font = "JetBrainsMono Nerd Font Mono"
local text_font_size = 9
local icon_font_size = 22.5

-- Helper function to create text-based icons using Nerd Font glyphs
local function create_icon_surface(glyph, size, fg_color, bg_color)
	size = size or icon_font_size
	fg_color = fg_color or theme.fg_normal or "#ffffff"
	bg_color = bg_color or "transparent"

	local surface = gears.surface.widget_to_surface(
		wibox.widget({
			{
				text = glyph,
				font = nerd_font .. " " .. size,
				align = "center",
				valign = "center",
				widget = wibox.widget.textbox,
			},
			forced_width = size * 2,
			forced_height = size * 2,
			bg = bg_color,
			fg = fg_color,
			widget = wibox.container.background,
		}),
		size * 2,
		size * 2
	)
	return surface
end

-- Define Nerd Font glyphs for various icons
-- You can find these glyphs at: https://www.nerdfonts.com/cheat-sheet
local nerd_glyphs = {
	-- Awesome
	awesome = "", -- nf-linux-awesome

	-- Menu icons
	submenu = "󰅂", -- nf-md-chevron_right

	-- Titlebar button icons
	close = "", -- nf-cod-chrome_close
	minimize = "", -- nf-cod-chrome_minimize
	maximize = "", -- nf-cod-chrome_maximize
	maximize_active = "", -- nf-cod-chrome_restore

	-- Window state icons
	floating = "󱇙", -- nf-md-view_grid_outline
	floating_active = "󰀾", -- nf-md-arrange_bring_to_front
	ontop = "󰕔", -- nf-md-vector_arrange_above
	ontop_active = "󰀽", -- nf-md-arrange_bring_forward
	sticky = "󰤰", -- nf-md-pin_off_outline
	sticky_active = "󰐃", -- nf-md-pin

	-- Layout icons
	tile = "󰕴", -- nf-md-view_quilt
	tileleft = "󰯌", -- nf-md-view_split_vertical
	tilebottom = "󰯋", -- nf-md-view_split_horizontal
	tiletop = "󱢈", -- nf-md-view_gallery
	fairv = "󰕭", -- nf-md-view_column
	fairh = "󰜩", -- nf-md-view_sequential
	spiral = "", -- nf-fa-arrow_rotate_right
	dwindle = "󰦺", -- nf-md-arrow_bottom_right_thick
	max = "󰖯", -- nf-md-window_maximize
	fullscreen = "", -- nf-fa-maximize
	magnifier = "", -- nf-fa-magnifying_glass
	floating_layout = "󰕬", -- nf-md-view_carousel
	cornernw = "󱥨", -- nf-md-arrow_top_left_bold_box
	cornerne = "󱥪", -- nf-md-arrow_top_right_bold_box
	cornersw = "󱥤", -- nf-md-arrow_bottom_left_bold_box
	cornerse = "󱥦", -- nf-md-arrow_bottom_right_bold_box

	-- Application menu icons
	terminal = "", -- nf-oct-terminal
	editor = "", -- nf-fa-edit
	browser = "󰖟", -- nf-md-web
	files = "󰉋", -- nf-md-folder
	music = "󰝚", -- nf-md-music

	-- System icons
	volume_high = "󰕾", -- nf-md-volume_high
	volume_medium = "󰖀", -- nf-md-volume_medium
	volume_low = "󰕿", -- nf-md-volume_low
	volume_muted = "󰖁", -- nf-md-volume_off
	battery_full = "󰁹", -- nf-md-battery
	battery_charging = "󰂄", -- nf-md-battery_charging
	wifi = "󰤨", -- nf-md-wifi
	bluetooth = "󰂯", -- nf-md-bluetooth
}

-- Begin defining the actual theme
local theme = {}

theme.font = nerd_font .. " " .. text_font_size

theme.bg_normal = "#282828"
theme.bg_focus = "#3c3836"
theme.bg_urgent = "#c14a4a"
theme.bg_minimize = "#141617"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#ddc7a1"
theme.fg_focus = "#ddc7a1"
theme.fg_urgent = "#f9f5d7"
theme.fg_minimize = "#d4be98"

theme.useless_gap = dpi(0)
theme.border_width = dpi(1)
theme.border_color_normal = theme.bg_normal
theme.border_color_active = theme.bg_focus
theme.border_color_marked = "#a9b665"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
theme.tooltip_bg = theme.bg_minimize
theme.tooltip_fg = theme.fg_minimize

theme.hotkeys_fg = theme.fg_minimize
theme.hotkeys_modifiers_fg = theme.fg_focus
theme.hotkeys_label_fg = theme.bg_minimize

-- Generate taglist squares:
local taglist_square_size = dpi(text_font_size)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = create_icon_surface(nerd_glyphs.submenu, dpi(text_font_size), theme.fg_normal)
theme.menu_height = dpi(text_font_size * 2)
theme.menu_width = dpi(153)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.wallpaper_bg = theme.bg_minimize

-- Define the image to load
theme.titlebar_close_button_normal = create_icon_surface(nerd_glyphs.close, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_close_button_focus = create_icon_surface(nerd_glyphs.close, dpi(icon_font_size), theme.fg_urgent)

theme.titlebar_minimize_button_normal = create_icon_surface(nerd_glyphs.minimize, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_minimize_button_focus = create_icon_surface(nerd_glyphs.minimize, dpi(icon_font_size), theme.fg_urgent)

theme.titlebar_ontop_button_normal_inactive =
	create_icon_surface(nerd_glyphs.ontop, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_ontop_button_focus_inactive =
	create_icon_surface(nerd_glyphs.ontop, dpi(icon_font_size), theme.fg_urgent)
theme.titlebar_ontop_button_normal_active =
	create_icon_surface(nerd_glyphs.ontop_active, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_ontop_button_focus_active =
	create_icon_surface(nerd_glyphs.ontop_active, dpi(icon_font_size), theme.fg_urgent)

theme.titlebar_sticky_button_normal_inactive =
	create_icon_surface(nerd_glyphs.sticky, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_sticky_button_focus_inactive =
	create_icon_surface(nerd_glyphs.sticky, dpi(icon_font_size), theme.fg_urgent)
theme.titlebar_sticky_button_normal_active =
	create_icon_surface(nerd_glyphs.sticky_active, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_sticky_button_focus_active =
	create_icon_surface(nerd_glyphs.sticky_active, dpi(icon_font_size), theme.fg_urgent)

theme.titlebar_floating_button_normal_inactive =
	create_icon_surface(nerd_glyphs.floating, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_floating_button_focus_inactive =
	create_icon_surface(nerd_glyphs.floating, dpi(icon_font_size), theme.fg_urgent)
theme.titlebar_floating_button_normal_active =
	create_icon_surface(nerd_glyphs.floating_active, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_floating_button_focus_active =
	create_icon_surface(nerd_glyphs.floating_active, dpi(icon_font_size), theme.fg_urgent)

theme.titlebar_maximized_button_normal_inactive =
	create_icon_surface(nerd_glyphs.maximize, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_maximized_button_focus_inactive =
	create_icon_surface(nerd_glyphs.maximize, dpi(icon_font_size), theme.fg_urgent)
theme.titlebar_maximized_button_normal_active =
	create_icon_surface(nerd_glyphs.maximize_active, dpi(icon_font_size), theme.fg_normal)
theme.titlebar_maximized_button_focus_active =
	create_icon_surface(nerd_glyphs.maximize_active, dpi(icon_font_size), theme.fg_urgent)

-- You can use your own layout icons like this:
theme.layout_fairh = create_icon_surface(nerd_glyphs.fairh, dpi(icon_font_size), theme.fg_normal)
theme.layout_fairv = create_icon_surface(nerd_glyphs.fairv, dpi(icon_font_size), theme.fg_normal)
theme.layout_floating = create_icon_surface(nerd_glyphs.floating_layout, dpi(icon_font_size), theme.fg_normal)
theme.layout_magnifier = create_icon_surface(nerd_glyphs.magnifier, dpi(icon_font_size), theme.fg_normal)
theme.layout_max = create_icon_surface(nerd_glyphs.max, dpi(icon_font_size), theme.fg_normal)
theme.layout_fullscreen = create_icon_surface(nerd_glyphs.fullscreen, dpi(icon_font_size), theme.fg_normal)
theme.layout_tilebottom = create_icon_surface(nerd_glyphs.tilebottom, dpi(icon_font_size), theme.fg_normal)
theme.layout_tileleft = create_icon_surface(nerd_glyphs.tileleft, dpi(icon_font_size), theme.fg_normal)
theme.layout_tile = create_icon_surface(nerd_glyphs.tile, dpi(icon_font_size), theme.fg_normal)
theme.layout_tiletop = create_icon_surface(nerd_glyphs.tiletop, dpi(icon_font_size), theme.fg_normal)
theme.layout_spiral = create_icon_surface(nerd_glyphs.spiral, dpi(icon_font_size), theme.fg_normal)
theme.layout_dwindle = create_icon_surface(nerd_glyphs.dwindle, dpi(icon_font_size), theme.fg_normal)
theme.layout_cornernw = create_icon_surface(nerd_glyphs.cornernw, dpi(icon_font_size), theme.fg_normal)
theme.layout_cornerne = create_icon_surface(nerd_glyphs.cornerne, dpi(icon_font_size), theme.fg_normal)
theme.layout_cornersw = create_icon_surface(nerd_glyphs.cornersw, dpi(icon_font_size), theme.fg_normal)
theme.layout_cornerse = create_icon_surface(nerd_glyphs.cornerse, dpi(icon_font_size), theme.fg_normal)

-- Generate Awesome icon:
theme.awesome_icon = create_icon_surface(nerd_glyphs.awesome, dpi(icon_font_size), theme.fg_normal)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Set different colors for urgent notifications.
rnotification.connect_signal("request::rules", function()
	rnotification.append_rule({
		rule = { urgency = "critical" },
		properties = { bg = theme.bg_urgent, fg = theme.fg_urgent },
	})
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
