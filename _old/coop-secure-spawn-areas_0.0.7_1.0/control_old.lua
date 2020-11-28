-- Load global pretty pring function
require("util.pprint")


-- Load Gui code from another file
local Gui = require("gui.gui")
local gui = nil -- instance of the gui

-- Load Team
--local Team = require("prototypes.team")
local forces = {} -- List/table of all teams


-- EVENTS

-- Player instance is not created or available in on_init().
-- The chat instance seems to be not available as well.
script.on_init(function()
  local size_area_to_clone = settings.startup["size-area-to-clone"].value
  local hide_default_forces = settings.startup["hide-default-forces"].value
  -- game.print("size-area-to-clone = " .. size_area_to_clone)
  -- game.print("hide_default_forces = " .. tostring(hide_default_forces))
  init_teams()
end)


-- This is meant for 3 specific reasons and only
-- re-register conditional event handlers
-- re-setup meta tables
-- create local references to tables stored in the global table
script.on_load(function()
  gui = Gui:new(global.gui.player, global.gui.forces, global.gui.hide_default_forces)
  log("on_load executed")
end)


script.on_event(defines.events.on_player_joined_game, function (event)
  local player = game.get_player(event.player_index)
  game.print("Player " .. player.name .. " joined the game.")
end)


script.on_event(defines.events.on_pre_player_left_game, function (event)
  local player = game.get_player(event.player_index)
  game.print("Player " .. player.name .. " pre left the game.")
end)


script.on_event(defines.events.on_player_left_game, function (event)
  local player = game.get_player(event.player_index)
  game.print("Player " .. player.name .. " left the game.")
end)


-- Listen to the on player created event and create the mods icon
script.on_event(defines.events.on_player_created, function (event)
  local player = game.get_player(event.player_index)
  player.print("on_player_created: gui == nil" .. tostring(gui == nil))
  if(gui == nil)
  then
    player.print("on_player_created executed and creating gui instance as player " .. player.name)
    local hide_default_forces = settings.startup["hide-default-forces"].value
    gui = Gui:new(forces, hide_default_forces)

    table.insert(forces, game.forces.player)
    table.insert(forces, game.forces.neutral)
    table.insert(forces, game.forces.enemy)

    global.gui = gui
    player.print("on_player_created executed")
  else
    player.print("on_player_created executed, but gui instance already exists, as player " .. player.name)
  end
  gui:create_icon(player)
end)


script.on_event(defines.events.on_gui_click, function(event)
  gui:on_gui_click(event)
end)


script.on_event(defines.events.on_force_created, function(event)
  --game.print("Force " .. event.force.name .. " was added to the teams list.")
  --table.insert(forces, event.force)
end)


script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)

  local set_wall_type = settings.get_player_settings(player)["set-wall-type"].value
  -- log("set-wall-type = " .. set_wall_type)
  -- player.print("set-wall-type = " .. set_wall_type)

  local size_area_to_clone = settings.startup["size-area-to-clone"].value

  -- clone_starting_area(player, size_area_to_clone)

end)


-- FUNCTIONS

function init_teams()
  local player_force = game.forces["player"] -- default
  local neutral_force = game.forces["neutral"]
  local enemy_force = game.forces["enemy"] -- biter

  player_force.set_friend(player_force, true)
  player_force.set_friend(neutral_force, false)
  player_force.set_friend(enemy_force, false)
  player_force.set_cease_fire(player_force, true)
  player_force.set_cease_fire(neutral_force, true)
  player_force.set_cease_fire(enemy_force, false)

  neutral_force.set_friend(player_force, false)
  neutral_force.set_friend(neutral_force, true)
  neutral_force.set_friend(enemy_force, false)
  neutral_force.set_cease_fire(player_force, true)
  neutral_force.set_cease_fire(neutral_force, true)
  neutral_force.set_cease_fire(enemy_force, false)

  enemy_force.set_friend(player_force, false)
  enemy_force.set_friend(neutral_force, false)
  enemy_force.set_friend(enemy_force, true)
  enemy_force.set_cease_fire(player_force, false)
  enemy_force.set_cease_fire(neutral_force, false)
  enemy_force.set_cease_fire(enemy_force, true)

  --local player_team = Team:new(nil, player_force, { neutral_force }, )

  --table.insert(teams, player_force)
  --table.insert(teams, neutral_force)
  --table.insert(teams, enemy_force)
end

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