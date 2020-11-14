local gui_module = {}

local icon = nil -- top left litte symbol of the mod
local menu = nil -- menu gui for having a look on the exisiting teams/forces and the status of alliance
local teams = {} -- the actual team instances as a list


-- Listen to the on player created event and create the mods icon
script.on_event(defines.events.on_player_created, function (event)
    local player = game.get_player(event.player_index)

    if(icon == nil) then
        icon = player.gui.left.add
        {
            type = "sprite-button",
            name = "teams-menu-icon",
            sprite = "cssa-main-sprite-button",
            --clicked_sprite = "",
        }
    else
        log("gui icon already exists")
    end
end)


script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if (event.element.name == "teams-menu-icon")
    then
        if(menu == nil) then
            gui_module.create_menu(player)
        else
            menu.destroy()
        end
    end
end)


-- Creates the menu gui for showing, creating and adjusting forces
local function create_menu(player)
    menu = player.gui.center.add
    {
        type = "frame",
        name = "teams-menu-frame",
        direction = "horizontal",
        -- style = "LuaStyle-name",
    }
    menu.add
    {
        type = "label",
        name = "teams-menu-title",
        caption = "Teams / Forces"
    }
    local table_frame = menu.add
    {
        type = "frame",
        name = "teams-menu-table-frame",
        direction = "horizontal"
    }
    table_frame.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-name",
        caption = "Name"
    }
    table_frame.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-neutral",
        caption = "Neutral"
    }
end

gui_module.create_menu = create_menu
return gui_module