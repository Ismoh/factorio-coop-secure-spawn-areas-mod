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
        

        local player_force = game.forces["player"] -- default
        local neutral_force = game.forces["neutral"]
        local enemy_force = game.forces["enemy"] -- biter


        local force_name = "Test Team Name"
        local lua_force = game.forces[force_name]
        if(lua_force == nil)
        then
            lua_force = game.create_force(force_name)
        end
        
        local team = Team(player, lua_force, neutral_force, player_force, enemy_force)
        game.print("team.force.name = " .. team.force.name)
        game.print("team.player.name = " .. team.player.name)
        game.print("team.player.force.name = " .. team.player.force.name)

        -- set cease fire to neutrals (feuer einstellen)
        -- set spawn point of team/force
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


