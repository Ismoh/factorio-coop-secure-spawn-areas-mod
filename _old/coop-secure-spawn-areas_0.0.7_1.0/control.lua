require "gui.gui"

if not cssa_gui then cssa_gui = {} end

function cssa_gui.log(message)
    if false then
        for i, p in pairs(game.players) do
            local complete_message = "There was an error: "
            for k, msg in pairs(message) do
                complete_message = complete_message .. " " .. k .. " " .. msg .. "; "
            end
            complete_message = complete_message .. "! Send this to the mod owner!"
            p.print(complete_message, {r = 1, g = 0, b = 0, a = 1})
        end
    else
        error(serpent.dump(message, {compact = false, nocode = true, indent = ' '}))
    end
end

script.on_event(defines.events.on_player_created, function(event)
    local status, err = pcall(cssa_gui.new_player, event)
    if err then cssa_gui.log({"err_generic", "on_player_created", err}) end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local status, err = pcall(cssa_gui.on_gui_click, event)

    if err then
        if event.element.valid then
            cssa_gui.log({"err_specific", "on_gui_click", event.element.name, err})
        else
            cssa_gui.log({"err_generic", "on_gui_click", err})
        end
    end
end)