if not cssa_spawn_math then cssa_spawn_math = {} end

cssa_spawn_math.seed = 341

function cssa_spawn_math.get_new_spawn(player)
  local distance_between_spawns = settings.startup["distance-between-spawns"].value

  if(not global.generator or not global.generator.valid) then
    global.generator = game.create_random_generator()
  end

  -- if new_seed exceeds the max uint value of 4294967295, then reset
  -- to the max value the seed will effect the generator: 341
  -- https://lua-api.factorio.com/latest/LuaRandomGenerator.html#LuaRandomGenerator.re_seed
  log("game.tick " .. game.tick)
  cssa_spawn_math.seed = cssa_spawn_math.seed + game.tick * 341
  if cssa_spawn_math.seed > 4294967295 then cssa_spawn_math.seed = 341 end
  log("cssa_spawn_math.seed " .. cssa_spawn_math.seed)
  global.generator.re_seed(cssa_spawn_math.seed)

  local new_spawn_position = { x = 0, y = 0 }
  local spawn_cluster_count = 1
  local range = 1 -- think of default-spawn = 0, near = 1, mid-range = 2, far = 3, really-far = 4, ... and so on
  local is_spawn_in_use = true
  while is_spawn_in_use do
    local plus_minus_zero_x = global.generator(-1, 1)
    local plus_minus_zero_y = global.generator(-1, 1)
    log("plus_minus_zero_x = " .. plus_minus_zero_x)
    log("plus_minus_zero_y = " .. plus_minus_zero_y)

    range = math.floor(spawn_cluster_count / 8)
    if range == 0 then range = 1 end

    for key, entry in pairs(global.spawns) do
      new_spawn_position.x = plus_minus_zero_x * range * distance_between_spawns
      new_spawn_position.y = plus_minus_zero_y * range * distance_between_spawns
      -- snap to grid layout
      new_spawn_position.x = math.floor(new_spawn_position.x /32) * 32
      new_spawn_position.y = math.floor(new_spawn_position.y /32) * 32

      is_spawn_in_use = new_spawn_position.x == entry.position.x and new_spawn_position.y == entry.position.y

      log("spawn_cluster_count = " .. spawn_cluster_count ..
      ", range = " .. range ..
      ", new_spawn_position(x,y) = " .. new_spawn_position.x .. ", " .. new_spawn_position.y ..
      ", " .. entry.force_name .. "(x,y) = " .. entry.position.x .. ", " .. entry.position.y ..
      ", is_spawn_in_use = " .. tostring(is_spawn_in_use))
      if is_spawn_in_use then break end
    end

    spawn_cluster_count = spawn_cluster_count + 1 -- range = 1 -> 8, range = 2 -> 16, 24, 32, ..
    -- re-seed, because there wasn't any free spawn yet
    cssa_spawn_math.seed = cssa_spawn_math.seed + 341
    global.generator.re_seed(cssa_spawn_math.seed)
    log("spawn_cluster_count = " .. spawn_cluster_count)
  end

  log("new_spawn_position.x = snapped " .. tostring(new_spawn_position.x))
  log("new_spawn_position.y = snapped " .. tostring(new_spawn_position.y))

  global.spawns[player.force.name] = {force_name = player.force.name, position = new_spawn_position, spawn_created = false}

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