-- https://kallanreed.wordpress.com/2015/03/15/class-modules-in-lua/
-- another or better approach: https://www.youtube.com/watch?v=O15GoH7SDn0

local table_tostring = require("util.table-tostring")

-- First, I pre-declare a table that will act as both
-- the method table and the metatable. I do this because
-- I like to define my 'new' function before the other
-- functions so it's available if I want to return new
-- objects from within other functions in the module
local mt = {}

-- Next, define all of the module functions as local
-- functions. Doing it this way instead of directly
-- hanging the methods off of the class table, allows
-- for more flexibility to modify the internal
-- implementation separate from the exported interface.
-- This is aligned with catwell's approach.
 
-- Define the 'new' function. The member fields are
-- also defined here. Notice that that I'm setting the
-- metatable to mt (that's why it needed to be pre-decl'd)
local new = function(player, force, neutrals, allies, enemies)
    local team = {
        player = player, -- remove, because the player is already in players?
        force = force,
        neutrals = neutrals,
        allies = allies,
        enemies = enemies
    }
    
    player.force = force

    game.print("game print tostring(team) = " .. mt.__tostring(team))
    log("log tostring(team) = " .. mt.__tostring(team))

    return setmetatable(team, mt)
end

-- Define a tostring function
local tostring = function(self)
    return string.format(
        "player = %s, force = %s, neutrals = %s, allies = %s, enemies = %s",
        self.player.name,
        self.force.name,
        table_tostring(self.neutrals.players),
        table_tostring(self.allies.players),
        table_tostring(self.enemies.players)
    )
end

-- If the class had more methods, they would be
-- exported here. Because I'm also using mt for a
-- metatable, I can export metamethods too.
mt.__tostring = tostring

-- Now that the interface has been defined, I need to
-- set up the metatable. First the metatable needs to
-- use itself for method lookup.
mt.__index = mt

-- Next, because we don't want the method table to be
-- tampered with, hide the metatable. This line will
 -- make getmetatable(x) return an empty table instead
-- of the real metatable. If we didn't do this, consumers
-- could get the metatable and because it's also the method
-- table, could monkey patch the implementation.
mt.__metatable = {}

-- That's pretty much it. I also add a 'constructor'
-- to forward the arguments to the 'new' function.
--local ctor = function(cls, ...)
local ctor = function(cls, player, force, neutrals, allies, enemies)
    return new(player, force, neutrals, allies, enemies)
end

-- Finally return a table that can be called to get a new
-- object. You could also simply return a function or a
-- table with a 'new' member. It's all a matter of style and
-- what syntax you want your consumers to use.
return setmetatable({}, { __call = ctor })
