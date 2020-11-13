local teams_menu_data = {}

teams_menu_data.metatable = {__index = teams_menu_data}

function teams_menu_data.new(player)
    local module =
    {
        player = player
    }

    setmetatable(module, teams_menu_data.metatable)

    return module
end

function teams_menu_data:gui()
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

function teams_menu_data:destroy()
    self.player.gui.center["teams-menu-frame"].destroy()
    self.player = nil
    self = nil
end

return teams_menu_data