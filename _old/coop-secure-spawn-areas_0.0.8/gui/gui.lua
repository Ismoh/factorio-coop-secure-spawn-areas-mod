--https://github.com/narc0tiq/evoGUI/blob/master/evoGUI.lua

require "clone"

if not cssa_gui then cssa_gui = {} end
if not cssa_clone then cssa_clone = {} end

-- EVENTS

function cssa_gui.new_player(event)
    local player = game.players[event.player_index]

    cssa_gui.create_menu_icon(player)
end

function cssa_gui.on_gui_click(event)
    local player = game.players[event.player_index]

    local color_red = {r = 1, g = 0, b = 0, a = 1}
    local color_green = {0, 1, 0, 1}

    if (event.element.name == "cssa_gui_root")
    then
        cssa_gui.create_menu(player)
        return
    end

    if(event.element.name == "close-menu")
    then
        local menu = player.gui.screen.cssa_gui_menu
        if(menu ~= nil)
        then
            menu.destroy()
        end

        return
    end

    if (event.element.name == "teams-menu-new-force-button")
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

        player.print("Force '" .. text .. "' created.", color_green)

        local menu = player.gui.screen.cssa_gui_menu
        if(menu ~= nil)
        then
            menu.destroy()
            cssa_gui.create_menu(player)
        end

        return
    end

    if(event.element.name == "teams-menu-join-force-button")
    then
        local dropdown = event.element.parent["teams-menu-join-force-drop-down"]
        local selected_force = dropdown.items[dropdown.selected_index]
        if(selected_force == nil or selected_force == '')
        then
            player.print("Unable to join 'undefined' force!", color_red)
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

        local menu = player.gui.screen.cssa_gui_menu
        if(menu ~= nil)
        then
            menu.destroy()
            cssa_gui.create_menu(player)
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

        local menu = player.gui.screen.cssa_gui_menu
        if(menu ~= nil)
        then
            menu.destroy()
            cssa_gui.create_menu(player)
        end

        return
    end

    if (event.element.name == "teams-menu-table-frame-" .. player.force.name .. "-row-spawn-button")
    then
        for key, entry in pairs(global.spawns) do
            if(player.force.name == entry.force_name and entry.spawn_created)
            then
                player.print("There already was a new spawn created for '" .. player.force.name .. "'!", color_red)
                return
            end
        end
        local button = player.gui.screen.cssa_gui_menu["teams-menu-table"]["teams-menu-table-frame-" .. player.force.name .. "-row-spawn-button"]
        cssa_clone.clone_area(player)
        button.enabled = false
        return
    end

end

--
--
-- FUNCTIONS
--
--

function cssa_gui.create_menu_icon(player)
    local root = player.gui.top.cssa_gui_root
    local destroyed = false

    if root then
        player.gui.top.cssa_gui_root.destroy()
        destroyed = true
    end

    if not root or destroyed or not root.valid  then
        local root = player.gui.top.add{
            type = "sprite-button",
            name = "cssa_gui_root",
            sprite = "cssa-main-sprite-button"
        }
    end
end

function cssa_gui.create_menu(player)
    local menu = player.gui.screen.cssa_gui_menu

    if menu then
        player.gui.screen.cssa_gui_menu.destroy()
        return
    end

    if not menu or not menu.valid then
        local menu = player.gui.screen.add
        {
            type = "frame",
            name = "cssa_gui_menu",
            direction = "vertical",
            caption = "Forces"
        }
        menu.force_auto_center()

        local empty_drag_widget = menu.add
        {
            type = "empty-widget",
            style = "draggable_space"
        }
        empty_drag_widget.drag_target = menu

        menu.add{type="sprite-button", name="close-menu", sprite = "utility/close_white", style="frame_action_button"}

        local gui_table = menu.add
        {
            type = "table",
            name = "teams-menu-table",
            column_count = 6,
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
            name = "teams-menu-table-frame-first-row-spawn",
            caption = "Starting Area"
        }
        gui_table.add
        {
            type = "label",
            name = "teams-menu-table-frame-first-row-players",
            caption = "Players"
        }
        cssa_gui.create_entry_for_forces(player, gui_table)

        menu.add
        {
            type = "textfield",
            name = "teams-menu-new-force-textfield",
            caption = "Insert force name.."
        }
        menu.add
        {
            type = "button",
            name = "teams-menu-new-force-button",
            caption = "New Force"
        }
        cssa_gui.create_join_force(menu)
    end
end

function cssa_gui.create_entry_for_forces(player, gui_table)
    for key, force in pairs(game.forces) do

        local hide_default_forces = settings.startup["hide-default-forces"].value
        if(hide_default_forces)
        then
            if(force.name == "neutral" or force.name == "enemy")
            then
                goto continue
            end
        end

        game.print("create_entry_for_forces executed as " .. force.name .. " as player " .. player.name)

        -- second table row contains 5 elements
        gui_table.add
        {
            type = "label",
            name = "teams-menu-table-frame-" .. force.name .. "-name",
            caption = force.name
        }

        local allies_check = player.force.get_friend(force)
        local neutral_check = not player.force.get_friend(force) and player.force.get_cease_fire(force)
        local enemies_check = not player.force.get_friend(force) and not player.force.get_cease_fire(force)

        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-allies",
            caption = force.name, -- use caption for on gui click, to know the force
            state = allies_check,
            enabled = player.force.name ~= force.name
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-neutrals",
            caption = force.name, -- use caption for on gui click, to know the force
            state = neutral_check,
            enabled = player.force.name ~= force.name
        }
        gui_table.add
        {
            type = "checkbox",
            name = "teams-menu-table-frame-" .. force.name .. "-row-enemies",
            caption = force.name, -- use caption for on gui click, to know the force
            state = enemies_check,
            enabled = player.force.name ~= force.name
        }

        local enable_new_spawn = true
        if(global.spawns[force.name] ~= nil)
        then
            enable_new_spawn = not global.spawns[force.name].spawn_created
        end
        gui_table.add
        {
            type = "sprite-button",
            name = "teams-menu-table-frame-" .. force.name .. "-row-spawn-button",
            sprite = "utility/add",
            style = "frame_action_button",
            enabled = enable_new_spawn
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

function cssa_gui.create_join_force(menu)
    local forces_string = {}
    local forces_string_key = 0
    for key, force in pairs(game.forces) do

        local hide_default_forces = settings.startup["hide-default-forces"].value
        if(hide_default_forces)
        then
            -- player should be still able to join the default player force
            -- therefore exclude "player" in the if
            if(force.name == "neutral" or force.name == "enemy")
            then
                goto continue2
            end
        end

        forces_string_key = forces_string_key + 1
        table.insert(forces_string, forces_string_key, force.name)

        ::continue2::
    end

    menu.add
    {
        type = "drop-down",
        name = "teams-menu-join-force-drop-down",
        default_value = forces_string[1],
        items = forces_string
    }
    menu.add
    {
        type = "button",
        name = "teams-menu-join-force-button",
        caption = "Join selected force"
    }
end