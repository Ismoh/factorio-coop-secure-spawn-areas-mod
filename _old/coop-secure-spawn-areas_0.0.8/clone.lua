require "math.spawn_math"

if not cssa_clone then cssa_clone = {} end
if not cssa_spawn_math then cssa_spawn_math = {} end
--
--
-- EVENTS
--
--

function cssa_clone.on_entity_cloned(event)
    local source = event.source
    -- game.print(source.name)
    local destination = event.destination
    -- game.print(destination.name)

    if(destination.name == "character")
    then
      destination.destroy()
    end
end

--
--
-- FUNCTIONS
--
--
function cssa_clone.clone_area(player)
    local size_area_to_clone = math.floor(settings.startup["size-area-to-clone"].value /32) * 32
    local distance_between_spawns = settings.startup["distance-between-spawns"].value

    game.print("size-area-to-clone = " .. size_area_to_clone)

    local source_area = {
        left_top = {
          x = -size_area_to_clone,
          y = -size_area_to_clone
        },
        right_bottom = {
          x = size_area_to_clone,
          y = size_area_to_clone
        }
      }
      game.print("source_area: top_left.x = "
       .. source_area.left_top.x .. ", top_left.y = "
       .. source_area.left_top.y .. " ; right_bottom.x = "
       .. source_area.right_bottom.x .. ", right_bottom.y = "
       .. source_area.right_bottom.y)

      local new_spawn_position = cssa_spawn_math.get_new_spawn(player)

      local destination_area = {
        left_top = {
          x = new_spawn_position.x - size_area_to_clone,
          y = new_spawn_position.y - size_area_to_clone
        },
        right_bottom = {
          x = new_spawn_position.x + size_area_to_clone,
          y = new_spawn_position.y + size_area_to_clone
        }
      }
      game.print("destination_area: top_left.x = "
       .. destination_area.left_top.x .. ", top_left.y = "
       .. destination_area.left_top.y .. " ; right_bottom.x = "
       .. destination_area.right_bottom.x .. ", right_bottom.y = "
       .. destination_area.right_bottom.y)
            

       --game.player.surface.get_tile(1, 1)
      local enemy_entities = player.surface.find_entities_filtered{area=destination_area, radius=distance_between_spawns, force="enemy"}
      for e, entity in ipairs(enemy_entities) do
        log(entity.name)
        entity.destroy()
      end

      player.surface.clone_area{source_area=source_area,
                                destination_area=destination_area,
                                destination_surface=player.surface,
                                destination_force=player.force,
                                clone_tiles=true,
                                clone_entities=true,
                                clone_decoratives=true,
                                clear_destination=true,
                                expand_map=true}
      player.force.set_spawn_position(new_spawn_position, player.surface)
      player.teleport(new_spawn_position)
end
