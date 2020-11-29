if not cssa_spawn_math then cssa_spawn_math = {} end

function cssa_spawn_math.get_new_spawn(player)
  local distance_between_spawns = settings.startup["distance-between-spawns"].value
  local distance_ok = false

  if(not global.generator or not global.generator.valid) then
    global.generator = game.create_random_generator()
  end
  global.generator.re_seed(game.tick * game.ticks_played / 2)

  local plusMinus = global.generator()
  local random = global.generator(distance_between_spawns, 2 * distance_between_spawns)
  local random2 = global.generator(distance_between_spawns, 2 * distance_between_spawns)

  if(plusMinus <= 0.5)
  then
    random = random *-1
  else
    random2 = random2 *-1
  end

  local new_spawn_position = {
      x = random,
      y = random2
    }

  while not distance_ok do
    local distance_ok_each_force = false

    for key, entry in pairs(global.spawns) do
      local distance = math.sqrt(
        math.pow(entry.position.x - new_spawn_position.x, 2) +
        math.pow(entry.position.y - new_spawn_position.y, 2)
      )
      distance_ok_each_force = distance >= distance_between_spawns

      log(entry.force_name)
      log("distance = " .. distance)
      log("distance_ok_each_force = " .. tostring(distance_ok_each_force))

      if not distance_ok_each_force then
        distance_ok = false
        log("distance_ok_each_force = " .. tostring(distance_ok_each_force))
        new_spawn_position.x = global.generator(distance_between_spawns, 2 * distance_between_spawns)
        new_spawn_position.y = global.generator(distance_between_spawns, 2 * distance_between_spawns)
        --local newX = entry.position.x - math.sqrt(math.pow(distance_between_spawns, 2) - math.pow(entry.position.y - newY, 2))
      end
    end
    distance_ok = distance_ok_each_force
  end

  log("new_spawn_position.x = " .. tostring(new_spawn_position.x))
  log("new_spawn_position.y = " .. tostring(new_spawn_position.y))
  -- snap to grid layout
  new_spawn_position.x = math.floor(new_spawn_position.x /32) * 32
  new_spawn_position.y = math.floor(new_spawn_position.y /32) * 32
  log("new_spawn_position.x = rounded " .. tostring(new_spawn_position.x))
  log("new_spawn_position.y = rounded " .. tostring(new_spawn_position.y))

  --[[ 
  https://www.onlinemathe.de/forum/Kreis-Punkte-auf-der-Linie-Berechnen
  https://mathematikalpha.de/wp-content/uploads/2016/12/09-Kreis.pdf seit 981

  x(φ)=xM+R⋅sin(φ)
  y(φ)=yM+R⋅cos(φ)
  φ = winkel -> 1-360, steps 1
 ]]
 local outlines = {}
 for key, spawn in pairs(global.spawns) do
   local outline_points = {}
   if(not spawn.spawn_created)
   then
    for angle = 0, 360, 20 do
      local radius = distance_between_spawns/2
      local x = math.floor(spawn.position.x + radius * math.sin(angle))
      local y = math.floor(spawn.position.y + radius * math.cos(angle))
      local p = { x = x, y = y}
      table.insert(outline_points, p)
      log(tostring(angle))
      log("outline point for " .. spawn.force_name .. ": p=(" .. x .. ", " .. y .. ")")
      --player.force.unchart_chunk({x = x/32, y = y/32}, player.surface)
      --game.surfaces[1].create_entity({name="land-mine", amount=1, position={x, y}})
      local character = game.surfaces[1].create_entity{name = "character", position = {x, y}, force = "enemy"}
      game.surfaces[1].create_entity{name = "artillery-projectile", position = {player.position.x, player.position.y}, force = spawn.force_name, target = character, speed = 1}
      character.destroy()
    end
    local outline = { force_name = spawn.force_name, outline_points = outline_points }
    table.insert(outlines, outline)
  end
 end

  global.spawns[player.force.name] = {force_name = player.force.name, position = new_spawn_position, spawn_created = true}

  return new_spawn_position
end


-- distance berechnung: d = sqrt((x2 - x1)2 + (y2 - y1)2)
-- d2 = (x2 - x1)2 + (y2 - y1)2
-- d2 - (y2 - y1)2 = (x2 - x1)2
-- sqrt(d2 - (y2 - y1)2) = x2 - x1
-- sqrt(d2 - (y2 - y1)2) - x2 = -x1
-- (sqrt(d2 - (y2 - y1)2) - x2)*-1 = x1
-- x2 - sqrt(d^2 - (y2 - y1)^2) = x1 <- Wolfram Alpha
-- https://www.wolframalpha.com/input/?i=plot+0+-+sqrt%283000%5E2+-+%280+-+y1%29%5E2%29



function cssa_spawn_math.round(x, n)
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end