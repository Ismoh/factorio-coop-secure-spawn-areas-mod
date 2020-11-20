-- https://wiki.factorio.com/Tutorial:Mod_settings#The_setting_type_property

local default_starting_spawn_area = 150

data:extend({
    -- General Settings: This settings are defined by the host, because of "startup"
    {
        type = "int-setting",
        name = "size-area-to-clone",
        setting_type = "startup",
        minimum_value = 1,
        default_value = default_starting_spawn_area, -- represents the default starting spawn area
        order = "1"
    },
    {
        type = "int-setting",
        name = "distance-between-spawns",
        setting_type = "startup",
        minimum_value = default_starting_spawn_area, -- minimum = size-area-to-clone.default_value
        default_value = 2000,
        order = "2"
    },
    {
        type = "bool-setting",
        name = "clone-entities",
        setting_type = "startup",
        default_value = true,
        order = "3"
    },
    {
        type = "bool-setting",
        name = "clone-resources",
        setting_type = "startup",
        default_value = true,
        order = "4"
    },
    {
        type = "bool-setting",
        name = "hide-default-forces",
        setting_type = "startup",
        default_value = true,
        order = "5"
    },
    -- Security Settings: Some of them are configurable by each player: "runtime-per-user"
    {
        type = "int-setting",
        name = "size-area-of-additional-security",
        setting_type = "startup",
        minimum_value = 10,
        default_value = default_starting_spawn_area/2,
        order = "5"
    },
    {
        type = "string-setting",
        name = "set-wall-type",
        setting_type = "runtime-per-user",
        default_value = "none",
        allowed_values = {"none", "tree", "cliff", "stone-wall"},
        order = "6"
    },
    {
        type = "string-setting",
        name = "add-turrets",
        setting_type = "runtime-per-user",
        default_value = "none",
        allowed_values = {"none", "gun-turret", "laser-turret"},
        order = "7"
    }
})