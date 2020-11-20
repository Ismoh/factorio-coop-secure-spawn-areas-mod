local table_tostring = require("util.table-tostring")

local Gui = {}
Gui.__index = Gui


function Gui:__call(player, teams)
    local inst = setmetatable({}, self)
    inst:new(player, teams)
    return inst
end


function Gui:new(player, teams)
    local gui = {
        player = player,
        icon = nil,
        menu = nil,
        teams = teams
    }
    setmetatable(gui, self)
    return gui
end


function Gui:create_icon()
    if(self.icon == nil) then
        self.icon = self.player.gui.left.add
        {
            type = "sprite-button",
            name = "teams-menu-icon",
            sprite = "cssa-main-sprite-button"
        }
    else
        log("gui icon already exists")
    end
end


-- Creates the menu gui for showing, creating and adjusting forces
function Gui:create_menu()
    log("create_menu executed as " .. self.player.name)
    self.menu = self.player.gui.screen.add
    {
        type = "frame",
        name = "teams-menu-frame",
        direction = "vertical",
        caption = "Forces"
    }
    self.menu.force_auto_center()

    local empty_drag_widget = self.menu.add
    {
        type = "empty-widget",
        style = "draggable_space"
    }
    empty_drag_widget.drag_target = self.menu

    local gui_table = self.menu.add
    {
        type = "table",
        name = "teams-menu-table",
        column_count = 5,
        draw_vertical_lines = false,
        draw_horizontal_lines = false,
        draw_horizontal_line_after_headers = true,
        vertical_centering = true
    }

    -- first table row contains 5 elements as the headers
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-name",
        caption = "Name"
    }
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-neutral",
        caption = "Neutral"
    }
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-allies",
        caption = "Allies"
    }
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-enemies",
        caption = "Enemies"
    }
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-players",
        caption = "Players"
    }

    self:create_entry_for_teams(gui_table)
    self:create_new_force_button()
    self:create_join_force()
end


function Gui:create_entry_for_teams(gui_table)
    log("create_entry_for_teams executed as " .. self.player.name)
    for key, team in pairs(self.teams) do
        -- second table row contains 5 elements
        gui_table.add
        {
            type = "label",
            name = "teams-menu-table-frame-" .. team.name .. "-name",
            caption = team.name
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. team.name .. "-row-neutral",
            state = false
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. team.name .. "-row-allies",
            state = false
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. team.name .. "-row-enemies",
            state = false
        }
        local players_flow = gui_table.add
        {
            type = "flow",
            name = "teams-menu-table-frame-" .. team.name .. "-row-players",
            direction = "horizontal"
        }
        for key, player in pairs(team.players) do
            players_flow.add
            {
                type = "label",
                name = player.name,
                caption = player.name
            }
        end
    end
end


function Gui:create_new_force_button()
    self.menu.add
    {
        type = "textfield",
        name = "teams-menu-new-force-textfield",
        caption = "Insert force name.."
    }
    self.menu.add
    {
        type = "button",
        name = "teams-menu-new-force-button",
        caption = "New Force"
    }
end


function Gui:create_join_force()
    local teams_string = {}
    for key, team in pairs(self.teams) do
        table.insert(teams_string, key, team.name)
    end
    self.menu.add
    {
        type = "drop-down",
        name = "teams-menu-join-force-drop-down",
        default_value = teams_string[1],
        items = teams_string
    }
    self.menu.add
    {
        type = "button",
        name = "teams-menu-join-force-button",
        caption = "Join force"
    }
end


function Gui:tostring()
    return string.format(
        "icon = " .. self.icon,
        "menu = " .. self.menu,
        "teams = " .. self.teams
    )
end


function Gui:on_gui_click(event)
    log("gui.lua on_gui_click executed")
    local player = game.get_player(event.player_index)
    local color_red = {r = 1, g = 0, b = 0, a = 1}
    local color_green = {0, 1, 0, 1}

    if (event.element.name == "teams-menu-icon")
    then
        local menu_when_loaded = player.gui.screen["teams-menu-frame"]
        if(menu_when_loaded ~= nil)
        then
            self.menu = menu_when_loaded
        end
        -- When gui.menu was created (LuaGuiElement) and then destoryed gui.menu is not nil, but gui.menu.valid = false
        if(self.menu == nil or not self.menu.valid) then
            self:create_menu()
        else
            self.menu.destroy()
        end
        return
    end

    if (event.element.name == "teams-menu-new-force-button")
    -- https://forums.factorio.com/viewtopic.php?p=381130#p381130
    then
        local text = event.element.parent["teams-menu-new-force-textfield"].text
        if(text == nil or text == '')
        then
            player.print("New force must not be empty!", color_red)
            return
        end

        if(game.forces[text] ~= nil)
        then
            player.print("Force '" .. text .. "' already exists!", color_red)
            return
        end

        game.create_force(text)
        player.print("Force '" .. text .. "' created.", color_green)

        if(self.menu ~= nil)
        then
            self.menu.destroy()
            self:create_menu()
        end

        return
    end

    if(event.element.name == "teams-menu-join-force-button")
    then
        local dropdown = event.element.parent["teams-menu-join-force-drop-down"]
        local selected_force = dropdown.items[dropdown.selected_index]
        if(selected_force == nil or selected_force == '')
        then
            player.print("Unable to join undefined force!", color_red)
            return
        end

        if(game.forces[selected_force] == nil)
        then
            player.print("Force '" .. selected_force .. "' does not exists!", color_red)
            return
        end

        player.force = selected_force
        player.print("Force '" .. selected_force .. "' joined.", color_green)

        if(self.menu ~= nil)
        then
            self.menu.destroy()
            self:create_menu()
        end

        return
    end
end

return Gui