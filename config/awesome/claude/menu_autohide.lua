-- AwesomeWM Menu Auto-Hide Implementation
-- Add this to your rc.lua file BEFORE creating any menus

local awful = require("awful")
local gears = require("gears")

-- Table to keep track of all visible menus
local visible_menus = {}

-- Function to hide all visible menus
local function hide_all_menus()
    for menu, _ in pairs(visible_menus) do
        if menu and menu.wibox and menu.wibox.visible then
            menu:hide()
        end
    end
    visible_menus = {}
end

-- Function to check if a coordinate is inside a wibox
local function point_in_wibox(wibox_obj, x, y)
    if not wibox_obj or not wibox_obj.visible then
        return false
    end
    
    local geom = wibox_obj:geometry()
    return x >= geom.x and x <= geom.x + geom.width and
           y >= geom.y and y <= geom.y + geom.height
end

-- Function to check if click is inside any visible menu
local function click_in_any_menu(x, y)
    for menu, _ in pairs(visible_menus) do
        if menu and menu.wibox then
            if point_in_wibox(menu.wibox, x, y) then
                return true
            end
            
            -- Also check submenus
            if menu.child then
                local function check_submenu(submenu)
                    if submenu and submenu.wibox and point_in_wibox(submenu.wibox, x, y) then
                        return true
                    end
                    if submenu.child then
                        return check_submenu(submenu.child)
                    end
                    return false
                end
                if check_submenu(menu.child) then
                    return true
                end
            end
        end
    end
    return false
end

-- Store the original awful.menu constructor
local original_menu = awful.menu

-- Override awful.menu to add auto-hide functionality
awful.menu = function(args)
    local menu = original_menu(args)
    
    -- Store original show and hide functions
    local original_show = menu.show
    local original_hide = menu.hide
    local original_toggle = menu.toggle
    
    -- Override show function
    menu.show = function(self, show_args)
        -- Hide all other menus first
        hide_all_menus()
        
        -- Show this menu
        local result = original_show(self, show_args)
        
        -- Add to visible menus list
        visible_menus[self] = true
        
        return result
    end
    
    -- Override hide function to remove from tracking
    menu.hide = function(self, hide_args)
        local result = original_hide(self, hide_args)
        visible_menus[self] = nil
        return result
    end
    
    -- Override toggle function
    menu.toggle = function(self, toggle_args)
        if self.wibox and self.wibox.visible then
            self:hide()
        else
            self:show(toggle_args)
        end
    end
    
    return menu
end

-- Alternative approach: Use client focus signals to hide menus
-- This catches more cases like keyboard focus changes
client.connect_signal("focus", function(c)
    -- Small delay to allow menu actions to complete first
    gears.timer.start_new(0.1, function()
        hide_all_menus()
        return false -- Don't repeat
    end)
end)

-- Hide menus when switching tags
tag.connect_signal("property::selected", function()
    hide_all_menus()
end)

-- Hide menus when screen focus changes
screen.connect_signal("property::focus", function()
    hide_all_menus()
end)

-- Enhanced version with keyboard support
-- Hide menus on Escape key press
root.keys(gears.table.join(
    root.keys() or {},
    awful.key({}, "Escape", function()
        hide_all_menus()
    end)
))

-- Utility function to manually hide all menus (useful for custom bindings)
awesome.hide_all_menus = hide_all_menus

-- Debug function to see what menus are currently visible
awesome.get_visible_menus = function()
    local count = 0
    for menu, _ in pairs(visible_menus) do
        if menu and menu.wibox and menu.wibox.visible then
            count = count + 1
        end
    end
    return count
end