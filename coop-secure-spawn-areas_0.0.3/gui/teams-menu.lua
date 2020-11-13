local teams_menu_gui_data = {}

teams_menu_gui_data.metatable = {__index = teams_menu_gui_data}

function teams_menu_gui_data.new(player)
    local module =
    {
        player = player
    }

    setmetatable(module, teams_menu_gui_data.metatable)

    return module
end

--[[function teams_menu_gui_data.get(player)
    local module =
    {
        player = player
    }
    return getmetatable(module)
end]]--

function teams_menu_gui_data:gui()
    local frame = self.player.gui.center.add
    {
        type = "frame",
        name = "teams-menu-frame",
        direction = "horizontal",
        -- style = "LuaStyle-name",
    }
    frame.add
    {
        type = "button"
    }
end

function teams_menu_gui_data:destroy()
    self.player.gui.center["teams-menu-frame"].destroy()
end

return teams_menu_gui_data