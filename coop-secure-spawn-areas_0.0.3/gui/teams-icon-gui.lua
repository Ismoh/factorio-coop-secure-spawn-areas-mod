local teams_menu_data = require("gui.teams-menu")
local Team = require("prototypes.team")

local teams_menu = nil
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if (event.element.name == "teams-menu-button")
    then
        if(teams_menu == nil)
        then
            teams_menu = teams_menu_data.new(player)
            teams_menu:gui()
        else
            --teams_menu = teams_menu_gui_lib.metatable
            teams_menu:destroy()
            teams_menu = nil
        end
        
        local force_name = "Test Team Name"
        local lua_force = game.forces[force_name]
        if(lua_force == nil)
        then
            lua_force = game.create_force(force_name)
        end
        local lua_force_enemy = game.forces["enemy"] -- biter
        team = Team(player, lua_force, nil, nil, lua_force_enemy)
        game.print("team.force.name = " .. team.force.name)
        game.print("team.player.name = " .. team.player.name)
        game.print("team.player.force.name = " .. team.player.force.name)
        log("team = " .. team)

        --[[if (player.gui.center["teams-menu-frame"] ~= nil)
        then
            player.gui.center["teams-menu-frame"].destroy()
            return 1 -- finish this funtion
        end
        
        player.gui.center.add
        {
            type = "frame",
            name = "teams-menu-frame",
            direction = "horizontal",
            caption = "Teams"
        }

        -- add a label to the frame
        player.gui.center["teams-menu-frame"].add
        {
            type = "label",
            name = "teams-menu-description",
            caption = "This is a test" -- text or value
        }
        show_teams_menu = false
        ]]--
    end
end)

return
{
    create_teams_icon = function(player)
        player.gui.left.add
        {
            type = "sprite-button",
            name = "teams-menu-button",
            sprite = "cssa-main-sprite-button",
            --clicked_sprite = "",
        }
    end
}


