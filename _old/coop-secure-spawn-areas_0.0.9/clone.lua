require "math.spawn_math"

if not cssa_clone then cssa_clone = {} end
if not cssa_spawn_math then cssa_spawn_math = {} end
--
--
-- EVENTS
--
--

function cssa_clone.on_area_cloned(event)
  local size_area_to_clone = math.floor(settings.startup["size-area-to-clone"].value /32) * 32
  local center_of_destination_area = event.destination_force.get_spawn_position(event.destination_surface)

  local water_tile_type_names = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }
  local water_tiles = event.destination_surface.find_tiles_filtered{
    position = center_of_destination_area,
    radius = size_area_to_clone,
    name = water_tile_type_names
  }
  
  -- Fill water tiles with landfill inside the radius of the new spawn circle
  local new_tiles = {}
  for key, tile in pairs(water_tiles) do
    new_tiles[key] = {name="landfill", position=tile.position}
  end
  event.destination_surface.set_tiles(new_tiles)

  -- Remove all enemy entities inside of the new spawn circle
  local enemy_entities = event.destination_surface.find_entities_filtered{
    position = center_of_destination_area,
    radius = size_area_to_clone,
    force = "enemy"
  }
  for e, entity in ipairs(enemy_entities) do
    log(entity.name)
    entity.destroy()
  end

  -- Remove all the entities outside of the new spawn circle, which were cloned
  local entities_on_water = event.destination_surface.find_entities_filtered{
    area = event.destination_area
  }
  for e, entity in ipairs(entities_on_water) do
    local tile_below_destination_entity = event.destination_surface.get_tile(math.floor(entity.position.x), math.floor(entity.position.y))
    local water_tile_type_names = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }

    for key, tile_name in pairs(water_tile_type_names) do
        if(tile_below_destination_entity.name == tile_name
        and entity ~= nil
        and entity.valid) then
          log(entity.name .. " destory, because it was cloned on water.")
          entity.destroy()
          break
        end
    end
  end
end

function cssa_clone.on_entity_cloned(event)
    local destination = event.destination
    if(destination.name == "character") then
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
           
      player.surface.request_to_generate_chunks(new_spawn_position, math.floor(size_area_to_clone/32))
      player.surface.force_generate_chunk_requests()

      player.force.set_spawn_position(new_spawn_position, player.surface)

      player.surface.clone_area{source_area=source_area,
                                destination_area=destination_area,
                                destination_surface=player.surface,
                                destination_force=player.force,
                                clone_tiles=false,
                                clone_entities=true,
                                clone_decoratives=false,
                                clear_destination_entities=true,
                                expand_map=true}
      player.teleport(new_spawn_position)
end
