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
  local add_defense_multiplier = settings.startup["add-defense-multiplier"].value / 100
  local remove_biter_multiplier = settings.startup["remove-biter-multiplier"].value / 100 + 1
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
  -- add water for electricity
  local water_tile = {}
  for wx = -50, -60, -1 do
    for wy = -50, -60, -1 do
      table.insert(water_tile, {name="water", position={x = center_of_destination_area.x+wx, y = center_of_destination_area.y+wy}})
    end
  end
  event.destination_surface.set_tiles(water_tile)

  -- Remove all enemy entities inside of the new spawn circle
  local enemy_entities = event.destination_surface.find_entities_filtered{
    position = center_of_destination_area,
    radius = size_area_to_clone * remove_biter_multiplier,
    force = "enemy"
  }
  for e, entity in ipairs(enemy_entities) do
    log(entity.name)
    entity.destroy()
  end

  -- Remove all the entities outside of the new spawn circle, which were cloned and on water
  local entities_on_water = event.destination_surface.find_entities_filtered{
    area = event.destination_area
  }
  for e, entity in ipairs(entities_on_water) do
    local tile_below_destination_entity = event.destination_surface.get_tile(math.floor(entity.position.x), math.floor(entity.position.y))
    local water_tile_type_names = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" }

    for key, tile_name in pairs(water_tile_type_names) do
        if tile_below_destination_entity.name == tile_name
        and entity ~= nil
        and entity.valid then
          -- log(entity.name .. " destory, because it was cloned on water.")
          entity.destroy()
          break
        end
    end
  end

  --[[ 
  https://www.onlinemathe.de/forum/Kreis-Punkte-auf-der-Linie-Berechnen
  https://mathematikalpha.de/wp-content/uploads/2016/12/09-Kreis.pdf seit 981

  x(φ)=xM+R⋅sin(φ)
  y(φ)=yM+R⋅cos(φ)
  φ = winkel -> 1-360, steps 1
  ]]
  local player = event.destination_force.players[1]
  -- local wall_type = settings.get_player_settings(player)["wall-types"].value
  -- local turret_type = settings.get_player_settings(player)["turret-types"].value
  -- local steps = size_area_to_clone / 100000
  -- log("steps = " .. steps)

  -- for key, spawn in pairs(global.spawns) do
  --   if not spawn.spawn_created then
  --     for angle = 0, 360, steps do
  --       log(tostring(angle))
  --       local radius_wall = 150 --0 + size_area_to_clone * add_defense_multiplier
  --       local x_wall = math.floor(spawn.position.x + radius_wall * math.sin(angle))
  --       local y_wall = math.floor(spawn.position.y + radius_wall * math.cos(angle))

  --       if wall_type ~= "none" then
  --         game.surfaces[1].create_entity{name = wall_type, position = {x_wall, y_wall}, force = event.destination_force}
  --         log("build wall at " .. spawn.force_name .. ": p=(" .. x_wall .. ", " .. y_wall .. ")")
  --       end

  --       local radius_turrets = 130 --0 + (size_area_to_clone * add_defense_multiplier) - 25
  --       local x_turrets = math.floor(spawn.position.x + radius_turrets * math.sin(angle))
  --       local y_turrets = math.floor(spawn.position.y + radius_turrets * math.cos(angle))
  --       local set_turret = math.fmod(math.floor(angle), 5)
  --       log("angle = " .. angle .. ", math.floor(angle) = " .. math.floor(angle) .. ", math.fmod(math.floor(angle), 2) = " .. set_turret)

  --       if turret_type ~= "none" and set_turret == 0 then
  --         log("try to set turret at " .. x_turrets .. ", " .. y_turrets)
  --         game.surfaces[1].create_entity{name = turret_type, position = {x_turrets, y_turrets}, force = event.destination_force}
  --       end
  --     end
  --   end
  -- end
  --player.insert({name = "stone-wall", count = 800})
  --player.insert({name = "gun-turret", count = 50})
  --player.insert({name = "firearm-magazine", count = 1000})

  -- create wall and turrets for this new created spawn
  local wall_type = settings.get_player_settings(player)["wall-types"].value
  local turret_type = settings.get_player_settings(player)["turret-types"].value
  local secure_area = settings.startup["secure-area"].value
  local edges = 0 -- 0 top, 1 right, 2 bottom, 3 left
  local start_pos = center_of_destination_area
  local x_wall = start_pos.x - secure_area / 2
  local y_wall = start_pos.y - secure_area / 2
  local x_turret = x_wall
  local y_turret = y_wall

  while edges <= 3 do
    local i = 0
    if edges == 0 then -- top
      x_turret = x_turret + 1
      y_turret = y_turret + 2
    end
    if edges == 2 then -- bottom
      x_turret = x_turret + 1
      y_turret = y_turret - 2
    end
    if edges == 1 then -- right
      x_turret = x_turret - 2
      y_turret = y_turret - 1
    end
    if edges == 3 then -- left
      x_turret = x_turret + 2
      y_turret = y_turret + 1
    end

    while i <= secure_area do
      if edges == 0 then -- top
        x_wall = x_wall + 1
        x_turret = x_turret + 1
      end
      if edges == 2 then -- bottom
        x_wall = x_wall - 1
        x_turret = x_turret - 1
      end
      if edges == 1 then -- right
        y_wall = y_wall + 1
        y_turret = y_turret + 1
      end
      if edges == 3 then -- left
        y_wall = y_wall - 1
        y_turret = y_turret - 1
      end

      if wall_type ~= "none" then
        local non_palyer_entities = game.surfaces[1].find_entities_filtered{
          area = {left_top = {x_wall-5, y_wall-5}, right_bottom = {x_wall+5, y_wall+5}},
          force = event.destination_force,
          invert = true
        }
        for e, entity in ipairs(non_palyer_entities) do
          log(entity.name)
          entity.destroy()
        end
        game.surfaces[1].create_entity{name = wall_type, position = {x_wall, y_wall}, force = event.destination_force}
        log("build wall at " .. event.destination_force.name .. ": p=(" .. x_wall .. ", " .. y_wall .. ")")
      end

      local set_turret = math.fmod(math.floor(i), 10)
      if turret_type ~= "none" and set_turret == 0 and i ~= secure_area then
        log("try to set turret at " .. x_turret .. ", " .. y_turret)
        local turret = game.surfaces[1].create_entity{name = turret_type, position = {x_turret, y_turret}, force = event.destination_force}
        turret.insert({name = "rifle-magazine", count = 1000})
      end

      i = i + 1
    end
    edges = edges + 1
  end



  global.spawns[event.destination_force.name].spawn_created = true
  log(event.destination_force.name .. "spawn_created = " .. tostring(global.spawns[event.destination_force.name].spawn_created))
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

    --game.print("size-area-to-clone = " .. size_area_to_clone)

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
                                clear_destination_entities=false,
                                expand_map=true}
      player.teleport(new_spawn_position)
end
