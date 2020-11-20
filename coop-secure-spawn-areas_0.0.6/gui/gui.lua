local table_tostring = require("util.table-tostring")

local Gui = {}
Gui.__index = Gui


function Gui:__call(player, forces, hide_default_forces)
    local inst = setmetatable({}, self)
    inst:new(player, forces, hide_default_forces)
    return inst
end


function Gui:new(player, forces, hide_default_forces)
    local gui = {
        player = player,
        icon = nil,
        menu = nil,
        forces = forces,
        hide_default_forces = hide_default_forces
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
        name = "teams-menu-table-frame-first-row-allies",
        caption = "Allies"
    }
    gui_table.add
    {
        type = "label",
        name = "teams-menu-table-frame-first-row-neutral",
        caption = "Neutrals"
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

    self:create_entry_for_forces(gui_table)
    self:create_new_force_button()
    self:create_join_force()
end


function Gui:create_entry_for_forces(gui_table)
    log("create_entry_for_forces executed as " .. self.player.name)
    for key, force in pairs(self.forces) do

        if(self.hide_default_forces)
        then
            if(force.name == "player" or force.name == "neutral" or force.name == "enemy")
            then
                goto continue
            end
        end

        -- second table row contains 5 elements
        gui_table.add
        {
            type = "label",
            name = "teams-menu-table-frame-" .. force.name .. "-name",
            caption = force.name
        }

        local allies_check = self.player.force.get_friend(force)
        local neutral_check = not self.player.force.get_friend(force) and self.player.force.get_cease_fire(force)
        local enemies_check = not self.player.force.get_friend(force) and not self.player.force.get_cease_fire(force)

        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-allies",
            caption = force.name, -- use caption for on gui click, to know the force
            state = allies_check,
            enabled = self.player.force.name ~= force.name
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-neutrals",
            caption = force.name, -- use caption for on gui click, to know the force
            state = neutral_check,
            enabled = self.player.force.name ~= force.name
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-enemies",
            caption = force.name, -- use caption for on gui click, to know the force
            state = enemies_check,
            enabled = self.player.force.name ~= force.name
        }

        local players_flow = gui_table.add
        {
            type = "flow",
            name = "teams-menu-table-frame-" .. force.name .. "-row-players",
            direction = "horizontal"
        }
        for key, player in pairs(force.players) do
            players_flow.add
            {
                type = "label",
                name = player.name,
                caption = player.name
            }
        end

        ::continue::
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
    local forces_string = {}
    local forces_string_key = 0
    for key, force in pairs(self.forces) do
        forces_string_key = forces_string_key + 1
        table.insert(forces_string, forces_string_key, force.name)
    end
    self.menu.add
    {
        type = "drop-down",
        name = "teams-menu-join-force-drop-down",
        default_value = forces_string[1],
        items = forces_string
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
        "forces = " .. self.forces
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

        local created_force = game.create_force(text)

        local player_force = game.forces["player"] -- default
        local neutral_force = game.forces["neutral"]
        local enemy_force = game.forces["enemy"] -- biter

        created_force.set_friend(player_force, false)
        created_force.set_friend(neutral_force, false)
        created_force.set_friend(enemy_force, false)
        created_force.set_cease_fire(player_force, true)
        created_force.set_cease_fire(neutral_force, true)
        created_force.set_cease_fire(enemy_force, false)

        table.insert(self.forces, created_force)
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
        player.force.set_friend(player.force, true)
        player.force.set_cease_fire(player.force, true)
        player.print("Force '" .. selected_force .. "' joined.", color_green)

        if(self.menu ~= nil)
        then
            self.menu.destroy()
            self:create_menu()
        end

        return
    end

    if(event.element.type == "checkbox")
    then
        local checkbox = event.element
        local force = game.forces[checkbox.caption]

        if(string.find(checkbox.name, "allies"))
        then
            player.force.set_friend(force, checkbox.state)
            player.force.set_cease_fire(force, checkbox.state)

            force.set_friend(player.force, checkbox.state)
            force.set_cease_fire(player.force, checkbox.state)
        end

        if(string.find(checkbox.name, "neutrals"))
        then
            player.force.set_friend(force, not checkbox.state)
            player.force.set_cease_fire(force, checkbox.state)

            force.set_friend(player.force, not checkbox.state)
            force.set_cease_fire(player.force, checkbox.state)
        end

        if(string.find(checkbox.name, "enemies"))
        then
            player.force.set_friend(force, not checkbox.state)
            player.force.set_cease_fire(force, not checkbox.state)

            force.set_friend(player.force, not checkbox.state)
            force.set_cease_fire(player.force, not checkbox.state)
        end

        if(self.menu ~= nil)
        then
            self.menu.destroy()
            self:create_menu()
        end

        return
    end

end

return Gui