
local setmetatable, pairs, print = setmetatable, pairs, print
local floor = math.floor
local random = math.random
local Class = require "object".Class

local C = require "content"
local world = require "world"
local roomWrangle = require "roomWrangle"

local Room = world.Room

local SCREEN_HEIGHT = SCREEN_HEIGHT

local _ENV = {}

-- room entry is at (0,2)

---------------------------------------------------------- high-level

local altRoomGens = {}
function genNextRoom(totalDifficulty)

	-- assume 4/3 seconds to walk 10 tiles
	local roomLen = 30
	local difficulty = 4

	local mobs = {}

	local roomGen = makeFlatRoom
	
	-- cheap, reliable, dull way to make room harder: make it longer
	local function default(hardness)
		difficulty = difficulty + hardness
		roomLen = roomLen + hardness*4.5
	end
	
	local function add(hardness, mob, count)
		local newDifficulty = difficulty + hardness
		
		if newDifficulty > totalDifficulty then
			-- wrap up
			default(totalDifficulty - difficulty)
			
			totalDifficulty = difficulty
		else
			difficulty = newDifficulty
			for i = 1, count do
				mobs[#mobs + 1] = mob(0,SCREEN_HEIGHT - 6)
			end
		end
	end
	
	-- loop through ways to make the level harder
	while difficulty < totalDifficulty do
		local r = random(3)
	
		if r == 1 then
			--  Anvil to dodge
			add(1, C.Anvil, 1)
		elseif r == 2 then
			-- Sheep!
			add(1, C.Sheep, 1)
		else
			default(1)
		end
		
		
	end

	roomLen = floor(roomLen)

	return roomGen(roomLen, mobs)
	
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

function sprinkleMobs(room, mobs)
	local interval = room.w / (#mobs + 1)

	local x = interval/2
	for i = 1,#mobs do
		local dx = (random()-0.5) * interval/2
		
		mobs[i].x = x+dx
		room:add(mobs[i])
		--print(mobs[i], x)
		
		x = x + interval
	end
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
	local room = Room(w, h, C.GreenTiles)
	
	block(room, 0,0, w,h, world.BLANK)
	ink(room, 0,1, w-1,1, world.FLAT)
	for i = 0,w-1 do
		room:setGrid(i,0, i%2 == 1 and world.SOLID or world.STONE)
	end

	placeFlag(room, 2)
	sprinkleMobs(room, mobs)

	return room
	
end

function makeHillyRoom(len, mobs)
	local w, h = len, SCREEN_HEIGHT * 2
	local room = Room(w, h, C.GreenTiles)
	
	block(room, 0,0, w,h, world.BLANK)
	ink(room, 0,1, w-1,1, world.FLAT)
	for i = 0,w-1 do
		room:setGrid(i,0, i%2 == 1 and world.SOLID or world.STONE)
	end

	placeFlag(room, 2)
	sprinkleMobs(room, mobs)

	return room
	
end

return _ENV

