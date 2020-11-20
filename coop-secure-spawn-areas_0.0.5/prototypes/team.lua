-- https://www.youtube.com/watch?v=O15GoH7SDn0

local table_tostring = require("util.table-tostring")

local Team = {}
Team.__index = Team


function Team:__call(player, force, neutrals, allies, enemies)
    local inst = setmetatable({}, self)
    inst:new(player, force, neutrals, allies, enemies)
    return inst
end


function Team:new(player, force, neutrals, allies, enemies)
    local team = {
        player = player,
        force = force,
        neutrals = neutrals,
        allies = allies,
        enemies = enemies
    }
    player.force = force
    setmetatable(team, self)
    return team
end


function Team:tostring()
    return string.format(
        "Player = %s, Force = %s, Neutrals = %s, Allies = %s, Enemies = %s",
        self.player.name,
        self.force.name,
        table_tostring(self.neutrals.players),
        table_tostring(self.allies.players),
        table_tostring(self.enemies.players)
    )
end


return Team