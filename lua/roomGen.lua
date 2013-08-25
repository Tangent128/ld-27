
local setmetatable, pairs, print = setmetatable, pairs, print
local Class = require "object".Class

local content = require "content"
local world = require "world"

local Room = world.Room

local _ENV = {}

------------------------------------------------------ tile drawing

-- draw a (positive-increasing) line of tiles
function ink(room, sx, sy, tx, ty, tile)
	local x,y = sx, sy
	
	repeat
		room:setGrid(x,y,tile)
		
		if x < tx then x = x + 1 end
		--if x > tx then x = x - 1 end

		if y < ty then y = y + 1 end
		--if y > ty then y = y - 1 end

	until x >= tx and y >= ty
end

-- draw a block of tiles
function block(room, sx, sy, w, h, tile)
	for x = 0, w-1 do
		for y = 0, h-1 do
			room:setGrid(sx + x, sy + y, tile)
		end
	end
end

-------------------------------------------------------- room types

function makeDebugRoom(w, h)
	
	local room = Room(w,h, content.GreenTiles)
	
	room:add(content.Sheep(0,0))
	room:add(content.Sheep(2,2))
	room:add(content.Sheep(4,4))

	block(room, 0,0, w,h, world.BLANK)
	ink(room, 0,1, w,1, world.FLAT)
	ink(room, 0,0, w,0, world.SOLID)
	ink(room, 8,0, 8,4, world.STONE)

	--for x = 1,room.
	
	return room
end

return _ENV

