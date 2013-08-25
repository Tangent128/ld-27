
local setmetatable, pairs, print = setmetatable, pairs, print
local Class = require "object".Class

local content = require "content"
local world = require "world"

local Room = world.Room

local _ENV = {}

function makeDebugRoom()
	
	local room = Room(5,5, content.GreenTiles)
	
	room:add(content.Sheep(0,0))
	room:add(content.Sheep(2,2))
	room:add(content.Sheep(4,4))
	room:setGrid(3,0, world.FLAT)

	--for x = 1,room.
	
	return room
end

return _ENV

