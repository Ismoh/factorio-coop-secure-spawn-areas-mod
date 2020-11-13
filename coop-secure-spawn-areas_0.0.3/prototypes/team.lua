--https://www.tutorialspoint.com/lua/lua_object_oriented.htm
local team = {}

team.metatable = { __index = team}

function team.new(name, player, neutral, allied, enemy)
    local module =
    {
        name = name,
        neutrals = {},
        allies = {},
        enemies = {},
        players = {}
    }

    table.insert(module.neutrals, neutral)
    table.insert(module.allies, allied)
    table.insert(module.enemies, enemy)
    table.insert(module.players, player)

    setmetatable(module, team)

    return module
end

return team