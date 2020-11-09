script.on_event(defines.events.on_player_changed_position, function(event)  
    local player = game.get_player(event.player_index)

    local spawn_area_radius = player.surface.get_starting_area_radius()
    log("-(spawn_area_radius/4) " .. -(spawn_area_radius/4))
    local source_area = {left_top = {-(spawn_area_radius/4), -(spawn_area_radius/4)}, right_bottom = {(spawn_area_radius/4), (spawn_area_radius/4)}}
    log(source_area)
    player.surface.clone_area()

  end)




-- log("surface help: " .. game.get_player(1).surface.help())



-- local surface = game.player.surface
-- local entities = surface.find_entities_filtered{area = area, type = 'tree'}
-- for k, tree in pairs(entities) do
  -- local position = tree.position
  -- tree.destroy()
  -- surface.create_entity{name = 'small-biter', position = position}
-- end