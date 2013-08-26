
local setmetatable, pairs, print = setmetatable, pairs, print
local random = math.random
local Class = require "object".Class

local content = require "content"
local world = require "world"
local roomWrangle = require "roomWrangle"

local Room = world.Room

local SCREEN_HEIGHT = SCREEN_HEIGHT

local _ENV = {}

-- room entry is at (0,2)

---------------------------------------------------------- high-level

function genNextRoom(difficulty)

	local roomLen = 30

--	local r = random(4)
	
--	if()

	return makeFlatRoom(roomLen, {})
	
end

------------------------------------------------------ tile drawing

-- draw a (positive-increasing) line of tiles
function ink(room, sx, sy, tx, ty, tile)
	local x,y = sx, sy
	
	room:setGrid(x,y,tile)
	
	repeat
		
		if x < tx then x = x + 1 end
		--if x > tx then x = x - 1 end

		if y < ty then y = y + 1 end
		--if y > ty then y = y - 1 end

		room:setGrid(x,y,tile)
		--print("ink", x, y, tile.index)

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

---------------------------------------------------------- elements

function placeFlag(room, y, nextFunc)
	
	local flag = roomWrangle.Flag(room.w - 3, y)
	
	flag.nextRoom = nextFunc or genNextRoom
	
	room:add(flag)
	
end

-------------------------------------------------------- room types

function makeDebugRoom(w, h)
	
	local room = Room(w,h, content.GreenTiles)
	
	--room:add(content.Sheep(0,0))
	--room:add(content.Sheep(2,2))
	--room:add(content.Sheep(4,4))

	block(room, 0,0, w,h, world.BLANK)
	ink(room, 0,1, w-1,1, world.FLAT)
	for i = 0,w-1 do
		room:setGrid(i,0, i%2 == 1 and world.SOLID or world.STONE)
	end
	block(room, 8,0, 2,4, world.STONE)
	room:setGrid(w-3,2, world.LEDGE_LEFT)
	room:setGrid(w-2,2, world.FLAT)
	room:setGrid(w-1,2, world.LEDGE_RIGHT)
	ink(room, w-3,1, w-1,1, world.SOLID)
	
	placeFlag(room, 3, function() return makeDebugRoom2(w,h) end)
	
	return room
end

function makeDebugRoom2(w, h)
	local room = Room(w,h, content.GreenTiles)
	
	room:add(content.Bee(3,3))
	
	block(room, 0,0, w,h, world.M)
	ink(room, 0,1, w-1,1, world.STONE)
	ink(room, 0,0, w-1,0, world.PLAT)

	placeFlag(room, 2)

	return room
end

function makeFlatRoom(len, mobs)
	local w, h = len, SCREEN_HEIGHT * 2
	local room = Room(w, h, content.GreenTiles)
	
	block(room, 0,0, w,h, world.BLANK)
	ink(room, 0,1, w-1,1, world.FLAT)
	for i = 0,w-1 do
		room:setGrid(i,0, i%2 == 1 and world.SOLID or world.STONE)
	end

	placeFlag(room, 2)

	return room
	
end

return _ENV

