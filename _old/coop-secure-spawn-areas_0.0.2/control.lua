-- Player instance is not created or available in on_init().
-- The chat instance seems to be not available as well.
script.on_init(function()

  local size_area_to_clone = settings.startup["size-area-to-clone"].value
  log("size-area-to-clone = " .. size_area_to_clone)
  game.print("size-area-to-clone = " .. size_area_to_clone)

end)

script.on_event(defines.events.on_player_joined_game, function(event) 

  local player = game.get_player(event.player_index)

  local set_wall_type = settings.get_player_settings(player)["set-wall-type"].value
  log("set-wall-type = " .. set_wall_type)
  player.print("set-wall-type = " .. set_wall_type)

  local size_area_to_clone = settings.startup["size-area-to-clone"].value

  clone_starting_area(player, size_area_to_clone)

end)


function clone_starting_area(player, size_area_to_clone)
  local source_area = {
    left_top = {
      x = -(size_area_to_clone/4),
      y = -(size_area_to_clone/4)
    },
    right_bottom = {
      x = size_area_to_clone/4,
      y = size_area_to_clone/4
    }
  }

  local destination_area = {
    left_top = {
      x = -(size_area_to_clone/4) -size_area_to_clone,
      y = -(size_area_to_clone/4) -size_area_to_clone
    },
    right_bottom = {
      x = size_area_to_clone/4 -size_area_to_clone,
      y = size_area_to_clone/4 -size_area_to_clone
    }
  }

  local surface = player.surface
  local faction = player.force

  log(player)
  log("size: " .. size_area_to_clone)
  log("source_area['left_top'] : ")
  log(source_area["left_top"])
  log("source_area.left_top : ")
  log(source_area.left_top)
  
  log("destination_area['left_top'] : ")
  log(destination_area["left_top"])
  log("destination_area.left_top : ")
  log(destination_area.left_top)

  player.surface.clone_area{source_area=source_area,
                            destination_area=destination_area,
                            destination_surface=surface,
                            destination_force=faction,
                            clone_tiles=false,
                            clone_entities=true,
                            clone_decoratives=false,
                            clear_destination=false,
                            expand_map=true
                          }
end



--[[
  script.on_event(defines.events.on_player_changed_position, function(event)  
    local player = game.get_player(event.player_index)

    local spawn_area_radius = player.surface.get_starting_area_radius()
    log("-(spawn_area_radius/4) " .. -(spawn_area_radius/4))
    local source_area = {left_top = {-(spawn_area_radius/4), -(spawn_area_radius/4)}, right_bottom = {(spawn_area_radius/4), (spawn_area_radius/4)}}
    log(source_area)
    player.surface.clone_area()

  end)
--]]



-- log("surface help: " .. game.get_player(1).surface.help())



-- local surface = game.player.surface
-- local entities = surface.find_entities_filtered{area = area, type = 'tree'}
-- for k, tree in pairs(entities) do
  -- local position = tree.position
  -- tree.destroy()
  -- surface.create_entity{name = 'small-biter', position = position}
-- end