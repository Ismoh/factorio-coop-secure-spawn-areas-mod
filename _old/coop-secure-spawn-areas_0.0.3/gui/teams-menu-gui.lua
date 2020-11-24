local teams_menu_gui_lib = require("gui.teams-menu")

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if (event.element.name == "teams-menu-button")
    then
        if (player.gui.center["teams-menu-frame"] ~= nil)
        then
            player.gui.center["teams-menu-frame"].destroy()
            return 1 -- finish this funtion
        end

        local teams_menu = teams_menu_gui_lib.new(player)
        teams_menu:gui()
        --[[player.gui.center.add
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