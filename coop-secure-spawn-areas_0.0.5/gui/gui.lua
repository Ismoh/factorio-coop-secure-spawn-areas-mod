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
    self.menu = self.player.gui.screen.add
    {
        type = "frame",
        name = "teams-menu-frame",
        direction = "horizontal",
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
end


function Gui:create_entry_for_teams(gui_table)
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


function Gui:tostring()
    return string.format(
        "icon = " .. self.icon,
        "menu = " .. self.menu,
        "teams = " .. self.teams
    )
end


return Gui