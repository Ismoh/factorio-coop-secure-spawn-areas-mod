function create_gui(player)
    player.gui.left.add
    {
        type = "sprite-button",
        name = "teams-menu-button",
        sprite = "cssa-main-sprite-button",
        --clicked_sprite = "",
    }
end

local show_teams_menu = true
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if(event.element.name == "teams-menu-button")
    then
        if(show_teams_menu == false) -- show_teams_menu = false -> hide
        then
            show_teams_menu = true
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
    end
end)