-- Load global pretty pring function
require("util.pprint")

--Load GUI code from another files
local teams_icon_gui = require("gui/teams-icon-gui")
local teams_menu = require("gui/teams-menu")

-- Player instance is not created or available in on_init().
-- The chat instance seems to be not available as well.
script.on_init(function()
  local size_area_to_clone = settings.startup["size-area-to-clone"].value
  log("size-area-to-clone = " .. size_area_to_clone)
  game.print("size-area-to-clone = " .. size_area_to_clone)

end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)

  teams_icon_gui.create_teams_icon(player)

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