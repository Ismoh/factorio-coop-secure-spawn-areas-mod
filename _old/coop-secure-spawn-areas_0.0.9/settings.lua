-- https://wiki.factorio.com/Tutorial:Mod_settings#The_setting_type_property

local default_starting_spawn_area = 192 * 3

data:extend({
    -- General Settings: This settings are defined by the host, because of "startup"
    {
        type = "int-setting",
        name = "size-area-to-clone",
        setting_type = "startup",
        minimum_value = default_starting_spawn_area,
        default_value = default_starting_spawn_area, -- represents the default starting spawn area
        order = "1"
    },
    {
        type = "int-setting",
        name = "add-defense-multiplier",
        setting_type = "startup",
        minimum_value = 25,
        default_value = 100,
        order = "2"
    },
    {
        type = "int-setting",
        name = "remove-biter-multiplier",
        setting_type = "startup",
        minimum_value = 1,
        default_value = 25,
        order = "3"
    },
    {
        type = "int-setting",
        name = "distance-between-spawns",
        setting_type = "startup",
        minimum_value = default_starting_spawn_area, -- minimum = size-area-to-clone.default_value
        default_value = 2000,
        order = "4"
    },
    {
        type = "bool-setting",
        name = "clone-entities",
        setting_type = "startup",
        default_value = true,
        order = "5"
    },
    {
        type = "bool-setting",
        name = "clone-resources",
        setting_type = "startup",
        default_value = true,
        order = "6"
    },
    {
        type = "bool-setting",
        name = "hide-default-forces",
        setting_type = "startup",
        default_value = true,
        order = "7"
    },
    -- Security Settings: Some of them are configurable by each player: "runtime-per-user"
    {
        type = "int-setting",
        name = "secure-area",
        setting_type = "startup",
        minimum_value = 100,
        default_value = 200,
        order = "8"
    },
    {
        type = "string-setting",
        name = "wall-types",
        setting_type = "runtime-per-user",
        default_value = "none",
        allowed_values = {"none", "tree-02", "cliff", "stone-wall"},
        order = "9"
    },
    {
        type = "string-setting",
        name = "turret-types",
        setting_type = "runtime-per-user",
        default_value = "none",
        allowed_values = {"none", "gun-turret", "laser-turret"},
        order = "10"
    }
})