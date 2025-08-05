-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Custom code, mostly written by Anthropic's Claude
require("claude.menu_autohide")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification({
		urgency = "critical",
		title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
		message = message,
	})
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/gruvbox_material_dark_hard.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
main_menu = awful.menu({
	items = {
		{ "termux", terminal },
		{ "debian", terminal .. " -T Debian -e debian --tmux" },
		{ "kali", terminal .. " -T 'Kali Linux' -e kali --tmux" },
		{ "-------" },
		{
			"hotkeys",
			function()
				hotkeys_popup.show_help(nil, awful.screen.focused())
			end,
		},
		{ "restart", awesome.restart },
		{
			"quit",
			function()
				awesome.quit()
			end,
		},
	},
})

taskbar_launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = main_menu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.floating,
		awful.layout.suit.max,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.fair,
	})
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
	awful.wallpaper({
		screen = s,
		bg = beautiful.wallpaper_bg,
	})
end)
-- }}}

-- {{{ Window Context Menu
-- Function to generate a context menu for the current window. We define
-- this relatively early so that it can be called in multiple places.
local function window_context_menu(c)
	local function get_tag_items()
		local tag_items = {}
		local tags = awful.screen.focused().tags

		for i, tag in ipairs(tags) do
			table.insert(tag_items, {
				tag.name or ("Tag " .. i),
				function()
					c:move_to_tag(tag)
					tag:view_only()
				end,
			})
		end

		return tag_items
	end

	-- local function get_screen_items()
	-- 	local screen_items = {}
	--
	-- 	for s in screen do
	-- 		table.insert(screen_items, {
	-- 			"Screen " .. s.index,
	-- 			function()
	-- 				c:move_to_screen(s)
	-- 			end,
	-- 		})
	-- 	end
	--
	-- 	return screen_items
	-- end

	local function get_menu_items()
		return {
			{
				c.minimized and "(un)minimize" or "minimize",
				function()
					c.minimized = not c.minimized
					if not c.minimized then
						c:raise()
						c:activate()
					end
				end,
			},
			{
				c.maximized and "(un)maximize" or "maximize",
				function()
					c.maximized = not c.maximized
					c:raise()
				end,
			},
			{ "---" },
			{ "send to tag", get_tag_items() },
			-- { "send to screen", get_screen_items() },
			{ "---" },
			{
				(c.ontop and " " or " ") .. "always on top",
				function()
					c.ontop = not c.ontop
				end,
			},
			{
				(c.sticky and " " or " ") .. "sticky",
				function()
					c.sticky = not c.sticky
				end,
			},
			{
				(awful.client.floating.get(c) and " " or " ") .. "floating",
				function()
					awful.client.floating.toggle(c)
				end,
			},
			{ "---" },
			{
				"close",
				function()
					c:kill()
				end,
			},
		}
	end

	return function()
		return awful.menu({
			items = get_menu_items(),
		})
	end
end

-- }}}

-- {{{ Wibar

-- Create a textclock widget
taskbar_clock = wibox.widget.textclock("%Y-%m-%d @ %H:%M:%S")

screen.connect_signal("request::desktop_decoration", function(s)
	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.taskbar_desktop_layout = awful.widget.layoutbox({
		screen = s,
		buttons = {
			awful.button({}, 1, function()
				awful.layout.inc(1)
			end),
			awful.button({}, 3, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 4, function()
				awful.layout.inc(-1)
			end),
			awful.button({}, 5, function()
				awful.layout.inc(1)
			end),
		},
	})

	-- Create a taglist widget
	s.taskbar_tag_list = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = {
			awful.button({}, 1, function(t)
				t:view_only()
			end),
			awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
			awful.button({}, 3, awful.tag.viewtoggle),
			awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
			awful.button({}, 4, function(t)
				awful.tag.viewprev(t.screen)
			end),
			awful.button({}, 5, function(t)
				awful.tag.viewnext(t.screen)
			end),
		},
	})

	-- Create a tasklist widget
	s.taskbar_task_list = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({}, 1, function(c)
				c:activate({ context = "tasklist", action = "toggle_minimization" })
			end),
			awful.button({}, 3, function(c)
				-- awful.menu.client_list({ theme = { width = 250 } })
				local context_menu_creator = window_context_menu(c)
				local context_menu = context_menu_creator()
				context_menu:show()
			end),
			awful.button({}, 4, function()
				awful.client.focus.byidx(-1)
			end),
			awful.button({}, 5, function()
				awful.client.focus.byidx(1)
			end),
		},
	})

	-- Create the wibox
	s.taskbar = awful.wibar({
		position = "bottom", -- "top" looks better without titlebars, but see 655 - 696
		screen = s,
		widget = {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				taskbar_launcher,
				s.taskbar_tag_list,
			},
			s.taskbar_task_list, -- Middle widget
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				{
					widget = wibox.container.margin,
					left = 8,
					right = 8,
					taskbar_clock,
				},
				s.taskbar_desktop_layout,
			},
		},
	})
end)

-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
	awful.button({}, 3, function()
		main_menu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewprev),
	awful.button({}, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "w", function()
		main_menu:toggle()
	end, { description = "show main menu", group = "awesome" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:activate({ raise = true, context = "key.unminimize" })
		end
	end, { description = "restore minimized", group = "client" }),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { modkey },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Control" },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Shift" },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { modkey, "Control", "Shift" },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { modkey },
		keygroup = "numpad",
		description = "select layout directly",
		group = "layout",
		on_press = function(index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}),
})

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ modkey }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ modkey }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		awful.key({ modkey, "Shift" }, "c", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		awful.key(
			{ modkey, "Control" },
			"space",
			awful.client.floating.toggle,
			{ description = "toggle floating", group = "client" }
		),
		awful.key({ modkey, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		awful.key({ modkey }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		awful.key({ modkey }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		awful.key({ modkey }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ modkey }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ modkey, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ modkey, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),
	})
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	})

	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	})

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true },
	})

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }
end)
-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Window context menu
	local context_menu_creator = window_context_menu(c)

	-- buttons for the titlebar
	local buttons = {
		awful.button({}, 1, function()
			-- c:activate({ context = "titlebar", action = "mouse_move" })
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({ modkey }, 1, function()
			client.focus = c
			c:raise()
			local context_menu = context_menu_creator()
			context_menu:show()
		end),
		awful.button({}, 3, function()
			-- c:activate({ context = "titlebar", action = "mouse_resize" })
			client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end),
	}

	awful.titlebar(c).widget = {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				halign = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.minimizebutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	}
end)
-- }}}

-- {{{ Remove Titlebars from Maximized Windows
-- Based on https://stackoverflow.com/a/44120615 + https://stackoverflow.com/a/68643954

-- FIXME: This is actually a bit buggy. Old windows don't lose their
--        titlebar when switching from a floating layout, and windows
--        without a titlebar need to have their floating state toggled
--        before one will be added.

-- Convenience function to add or remove titlebars; creates a titlebar
-- if one doesn't already exist.
-- local function set_titlebar(client, state)
-- 	if state then
-- 		if client.titlebar == nil then
-- 			client:emit_signal("request::titlebars", "rules", {})
-- 		end
-- 		awful.titlebar.show(client)
-- 	else
-- 		awful.titlebar.hide(client)
-- 	end
-- end

-- Hook floating status change
-- client.connect_signal("property::floating", function(c)
-- 	set_titlebar(c, c.floating or c.first_tag and c.first_tag.layout.name == "floating")
-- end)

-- Hook window creation
-- client.connect_signal("manage", function(c)
-- 	set_titlebar(c, c.floating or c.first_tag.layout == awful.layout.suit.floating)
-- end)

-- Hook the entire floating layout
-- tag.connect_signal("propery::layout", function(t)
-- 	for _, c in pairs(t:clients()) do
-- 		if t.layout == awful.layout.suit.floating then
-- 			set_titlebar(c, true)
-- 		else
-- 			set_titlebar(c, false)
-- 		end
-- 	end
-- end)
-- }}}

-- {{{ Notifications

ruled.notification.connect_signal("request::rules", function()
	-- All notifications will match this rule.
	ruled.notification.append_rule({
		rule = {},
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
		},
	})
end)

naughty.connect_signal("request::display", function(n)
	naughty.layout.box({ notification = n })
end)

-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:activate({ context = "mouse_enter", raise = false })
end)

-- {{{ LICENSE: GPL 2.0
--                     GNU GENERAL PUBLIC LICENSE
--                        Version 2, June 1991
--
--  Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
--  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
--  Everyone is permitted to copy and distribute verbatim copies
--  of this license document, but changing it is not allowed.
--
--                             Preamble
--
--   The licenses for most software are designed to take away your
-- freedom to share and change it.  By contrast, the GNU General Public
-- License is intended to guarantee your freedom to share and change free
-- software--to make sure the software is free for all its users.  This
-- General Public License applies to most of the Free Software
-- Foundation's software and to any other program whose authors commit to
-- using it.  (Some other Free Software Foundation software is covered by
-- the GNU Lesser General Public License instead.)  You can apply it to
-- your programs, too.
--
--   When we speak of free software, we are referring to freedom, not
-- price.  Our General Public Licenses are designed to make sure that you
-- have the freedom to distribute copies of free software (and charge for
-- this service if you wish), that you receive source code or can get it
-- if you want it, that you can change the software or use pieces of it
-- in new free programs; and that you know you can do these things.
--
--   To protect your rights, we need to make restrictions that forbid
-- anyone to deny you these rights or to ask you to surrender the rights.
-- These restrictions translate to certain responsibilities for you if you
-- distribute copies of the software, or if you modify it.
--
--   For example, if you distribute copies of such a program, whether
-- gratis or for a fee, you must give the recipients all the rights that
-- you have.  You must make sure that they, too, receive or can get the
-- source code.  And you must show them these terms so they know their
-- rights.
--
--   We protect your rights with two steps: (1) copyright the software, and
-- (2) offer you this license which gives you legal permission to copy,
-- distribute and/or modify the software.
--
--   Also, for each author's protection and ours, we want to make certain
-- that everyone understands that there is no warranty for this free
-- software.  If the software is modified by someone else and passed on, we
-- want its recipients to know that what they have is not the original, so
-- that any problems introduced by others will not reflect on the original
-- authors' reputations.
--
--   Finally, any free program is threatened constantly by software
-- patents.  We wish to avoid the danger that redistributors of a free
-- program will individually obtain patent licenses, in effect making the
-- program proprietary.  To prevent this, we have made it clear that any
-- patent must be licensed for everyone's free use or not licensed at all.
--
--   The precise terms and conditions for copying, distribution and
-- modification follow.
--
--                     GNU GENERAL PUBLIC LICENSE
--    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
--
--   0. This License applies to any program or other work which contains
-- a notice placed by the copyright holder saying it may be distributed
-- under the terms of this General Public License.  The "Program", below,
-- refers to any such program or work, and a "work based on the Program"
-- means either the Program or any derivative work under copyright law:
-- that is to say, a work containing the Program or a portion of it,
-- either verbatim or with modifications and/or translated into another
-- language.  (Hereinafter, translation is included without limitation in
-- the term "modification".)  Each licensee is addressed as "you".
--
-- Activities other than copying, distribution and modification are not
-- covered by this License; they are outside its scope.  The act of
-- running the Program is not restricted, and the output from the Program
-- is covered only if its contents constitute a work based on the
-- Program (independent of having been made by running the Program).
-- Whether that is true depends on what the Program does.
--
--   1. You may copy and distribute verbatim copies of the Program's
-- source code as you receive it, in any medium, provided that you
-- conspicuously and appropriately publish on each copy an appropriate
-- copyright notice and disclaimer of warranty; keep intact all the
-- notices that refer to this License and to the absence of any warranty;
-- and give any other recipients of the Program a copy of this License
-- along with the Program.
--
-- You may charge a fee for the physical act of transferring a copy, and
-- you may at your option offer warranty protection in exchange for a fee.
--
--   2. You may modify your copy or copies of the Program or any portion
-- of it, thus forming a work based on the Program, and copy and
-- distribute such modifications or work under the terms of Section 1
-- above, provided that you also meet all of these conditions:
--
--     a) You must cause the modified files to carry prominent notices
--     stating that you changed the files and the date of any change.
--
--     b) You must cause any work that you distribute or publish, that in
--     whole or in part contains or is derived from the Program or any
--     part thereof, to be licensed as a whole at no charge to all third
--     parties under the terms of this License.
--
--     c) If the modified program normally reads commands interactively
--     when run, you must cause it, when started running for such
--     interactive use in the most ordinary way, to print or display an
--     announcement including an appropriate copyright notice and a
--     notice that there is no warranty (or else, saying that you provide
--     a warranty) and that users may redistribute the program under
--     these conditions, and telling the user how to view a copy of this
--     License.  (Exception: if the Program itself is interactive but
--     does not normally print such an announcement, your work based on
--     the Program is not required to print an announcement.)
--
-- These requirements apply to the modified work as a whole.  If
-- identifiable sections of that work are not derived from the Program,
-- and can be reasonably considered independent and separate works in
-- themselves, then this License, and its terms, do not apply to those
-- sections when you distribute them as separate works.  But when you
-- distribute the same sections as part of a whole which is a work based
-- on the Program, the distribution of the whole must be on the terms of
-- this License, whose permissions for other licensees extend to the
-- entire whole, and thus to each and every part regardless of who wrote it.
--
-- Thus, it is not the intent of this section to claim rights or contest
-- your rights to work written entirely by you; rather, the intent is to
-- exercise the right to control the distribution of derivative or
-- collective works based on the Program.
--
-- In addition, mere aggregation of another work not based on the Program
-- with the Program (or with a work based on the Program) on a volume of
-- a storage or distribution medium does not bring the other work under
-- the scope of this License.
--
--   3. You may copy and distribute the Program (or a work based on it,
-- under Section 2) in object code or executable form under the terms of
-- Sections 1 and 2 above provided that you also do one of the following:
--
--     a) Accompany it with the complete corresponding machine-readable
--     source code, which must be distributed under the terms of Sections
--     1 and 2 above on a medium customarily used for software interchange; or,
--
--     b) Accompany it with a written offer, valid for at least three
--     years, to give any third party, for a charge no more than your
--     cost of physically performing source distribution, a complete
--     machine-readable copy of the corresponding source code, to be
--     distributed under the terms of Sections 1 and 2 above on a medium
--     customarily used for software interchange; or,
--
--     c) Accompany it with the information you received as to the offer
--     to distribute corresponding source code.  (This alternative is
--     allowed only for noncommercial distribution and only if you
--     received the program in object code or executable form with such
--     an offer, in accord with Subsection b above.)
--
-- The source code for a work means the preferred form of the work for
-- making modifications to it.  For an executable work, complete source
-- code means all the source code for all modules it contains, plus any
-- associated interface definition files, plus the scripts used to
-- control compilation and installation of the executable.  However, as a
-- special exception, the source code distributed need not include
-- anything that is normally distributed (in either source or binary
-- form) with the major components (compiler, kernel, and so on) of the
-- operating system on which the executable runs, unless that component
-- itself accompanies the executable.
--
-- If distribution of executable or object code is made by offering
-- access to copy from a designated place, then offering equivalent
-- access to copy the source code from the same place counts as
-- distribution of the source code, even though third parties are not
-- compelled to copy the source along with the object code.
--
--   4. You may not copy, modify, sublicense, or distribute the Program
-- except as expressly provided under this License.  Any attempt
-- otherwise to copy, modify, sublicense or distribute the Program is
-- void, and will automatically terminate your rights under this License.
-- However, parties who have received copies, or rights, from you under
-- this License will not have their licenses terminated so long as such
-- parties remain in full compliance.
--
--   5. You are not required to accept this License, since you have not
-- signed it.  However, nothing else grants you permission to modify or
-- distribute the Program or its derivative works.  These actions are
-- prohibited by law if you do not accept this License.  Therefore, by
-- modifying or distributing the Program (or any work based on the
-- Program), you indicate your acceptance of this License to do so, and
-- all its terms and conditions for copying, distributing or modifying
-- the Program or works based on it.
--
--   6. Each time you redistribute the Program (or any work based on the
-- Program), the recipient automatically receives a license from the
-- original licensor to copy, distribute or modify the Program subject to
-- these terms and conditions.  You may not impose any further
-- restrictions on the recipients' exercise of the rights granted herein.
-- You are not responsible for enforcing compliance by third parties to
-- this License.
--
--   7. If, as a consequence of a court judgment or allegation of patent
-- infringement or for any other reason (not limited to patent issues),
-- conditions are imposed on you (whether by court order, agreement or
-- otherwise) that contradict the conditions of this License, they do not
-- excuse you from the conditions of this License.  If you cannot
-- distribute so as to satisfy simultaneously your obligations under this
-- License and any other pertinent obligations, then as a consequence you
-- may not distribute the Program at all.  For example, if a patent
-- license would not permit royalty-free redistribution of the Program by
-- all those who receive copies directly or indirectly through you, then
-- the only way you could satisfy both it and this License would be to
-- refrain entirely from distribution of the Program.
--
-- If any portion of this section is held invalid or unenforceable under
-- any particular circumstance, the balance of the section is intended to
-- apply and the section as a whole is intended to apply in other
-- circumstances.
--
-- It is not the purpose of this section to induce you to infringe any
-- patents or other property right claims or to contest validity of any
-- such claims; this section has the sole purpose of protecting the
-- integrity of the free software distribution system, which is
-- implemented by public license practices.  Many people have made
-- generous contributions to the wide range of software distributed
-- through that system in reliance on consistent application of that
-- system; it is up to the author/donor to decide if he or she is willing
-- to distribute software through any other system and a licensee cannot
-- impose that choice.
--
-- This section is intended to make thoroughly clear what is believed to
-- be a consequence of the rest of this License.
--
--   8. If the distribution and/or use of the Program is restricted in
-- certain countries either by patents or by copyrighted interfaces, the
-- original copyright holder who places the Program under this License
-- may add an explicit geographical distribution limitation excluding
-- those countries, so that distribution is permitted only in or among
-- countries not thus excluded.  In such case, this License incorporates
-- the limitation as if written in the body of this License.
--
--   9. The Free Software Foundation may publish revised and/or new versions
-- of the General Public License from time to time.  Such new versions will
-- be similar in spirit to the present version, but may differ in detail to
-- address new problems or concerns.
--
-- Each version is given a distinguishing version number.  If the Program
-- specifies a version number of this License which applies to it and "any
-- later version", you have the option of following the terms and conditions
-- either of that version or of any later version published by the Free
-- Software Foundation.  If the Program does not specify a version number of
-- this License, you may choose any version ever published by the Free Software
-- Foundation.
--
--   10. If you wish to incorporate parts of the Program into other free
-- programs whose distribution conditions are different, write to the author
-- to ask for permission.  For software which is copyrighted by the Free
-- Software Foundation, write to the Free Software Foundation; we sometimes
-- make exceptions for this.  Our decision will be guided by the two goals
-- of preserving the free status of all derivatives of our free software and
-- of promoting the sharing and reuse of software generally.
--
--                             NO WARRANTY
--
--   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
-- FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
-- OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
-- PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
-- OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
-- TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
-- PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
-- REPAIR OR CORRECTION.
--
--   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
-- WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
-- REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
-- INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
-- OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
-- TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
-- YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
-- PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGES.
--
--                      END OF TERMS AND CONDITIONS
--
--             How to Apply These Terms to Your New Programs
--
--   If you develop a new program, and you want it to be of the greatest
-- possible use to the public, the best way to achieve this is to make it
-- free software which everyone can redistribute and change under these terms.
--
--   To do so, attach the following notices to the program.  It is safest
-- to attach them to the start of each source file to most effectively
-- convey the exclusion of warranty; and each file should have at least
-- the "copyright" line and a pointer to where the full notice is found.
--
--     <one line to give the program's name and a brief idea of what it does.>
--     Copyright (C) <year>  <name of author>
--
--     This program is free software; you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation; either version 2 of the License, or
--     (at your option) any later version.
--
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
--
--     You should have received a copy of the GNU General Public License along
--     with this program; if not, write to the Free Software Foundation, Inc.,
--     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--
-- Also add information on how to contact you by electronic and paper mail.
--
-- If the program is interactive, make it output a short notice like this
-- when it starts in an interactive mode:
--
--     Gnomovision version 69, Copyright (C) year name of author
--     Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
--     This is free software, and you are welcome to redistribute it
--     under certain conditions; type `show c' for details.
--
-- The hypothetical commands `show w' and `show c' should show the appropriate
-- parts of the General Public License.  Of course, the commands you use may
-- be called something other than `show w' and `show c'; they could even be
-- mouse-clicks or menu items--whatever suits your program.
--
-- You should also get your employer (if you work as a programmer) or your
-- school, if any, to sign a "copyright disclaimer" for the program, if
-- necessary.  Here is a sample; alter the names:
--
--   Yoyodyne, Inc., hereby disclaims all copyright interest in the program
--   `Gnomovision' (which makes passes at compilers) written by James Hacker.
--
--   <signature of Ty Coon>, 1 April 1989
--   Ty Coon, President of Vice
--
-- This General Public License does not permit incorporating your program into
-- proprietary programs.  If your program is a subroutine library, you may
-- consider it more useful to permit linking proprietary applications with the
-- library.  If this is what you want to do, use the GNU Lesser General
-- Public License instead of this License.
-- }}}
