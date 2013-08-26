
local setmetatable, pairs, print = setmetatable, pairs, print
local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max
local coroutine = coroutine

local beginSprites, endSprites = g.beginSprites, g.endSprites

local Class = require "object".Class
local _ENV = {}

GRAVITY = -0.1

-- global state
hero = false
camera = false
timer = 10000
rooms = {} -- list of currently valid rooms

------------------------------------------------------------ Sprite Objects

Sprite = Class()

Sprite.solid = true

function Sprite:init(x, y, frame, sheet)
	-- sheet can be inherited from prototype
	self.sheet = sheet

	-- current frame
	self.frame = frame

	-- location
	self.x = x or 0
	self.y = y or 0
	
	-- bounds (must be integral)
	self.w = self.sheet.scale
	self.h = self.sheet.scale
	
	self.flip = false
	
	-- speed
	self.vx = 0
	self.vy = 0
	
	-- physics signals
	self.collideSide = false
	self.onGround = false
	self.hitCeiling = false
	
	if self.brain then
		self.tick = self:wrap(self.brain)
	end
end

function Sprite:input(mx, my, kU, kD, kL, kR, kSpace, kEscape)
end

function Sprite:tick(timeDiff)
end

function Sprite:render()
	self.sheet:draw(self.x, self.y, self.frame, self.flip)
end

function Sprite:locateHero()
	local myRoom = self.room
	
	if hero then
		local heroRoom = hero.room
		local x = hero.x + heroRoom.x - myRoom.x
		local y = hero.y + heroRoom.y - myRoom.y
		return x, y
	else
		return self.x, self.y
	end
end

function Sprite:normalizeSpeed(maxSpeed, minSpeed)
	minSpeed = minSpeed or maxSpeed
	local magnitude = ( (self.vx^2) +(self.vy^2))^0.5 

	-- handle zero/near-zero vectors
	if magnitude <= 0.001 then magnitude = 0.001 end

	-- accept slower speeds without modification
	if magnitude < minSpeed then magnitude = maxSpeed end

	self.vx = self.vx * maxSpeed / magnitude
	self.vy = self.vy * maxSpeed / magnitude
end

-- iterator for all the sprites in the room
function Sprite:loopAllSprites()
	return coroutine.wrap(function()
		for _, room in pairs(rooms) do
			for sprite in pairs(room.sprites) do
				if sprite ~= self and sprite.solid then
					coroutine.yield(sprite)
				end
			end
		end
	end)
end

function Sprite:intersect(other)

	if self.room ~= other.room then return false end

	if self.x + self.w < other.x then return false end
	if self.x > other.x + other.w then return false end
	if self.y + self.h < other.y then return false end
	if self.y > other.y + other.h then return false end
	
	return true
end

function Sprite:spawn(dx, dy, obj)
	obj.x = self.x + dx
	obj.y = self.y + dy
	self.room:add(obj)
end

function Sprite:die()
	self.room:remove(self)
end

------------------------------------------------------------ Sprite Physics

function Sprite:gravityPhysics(boundsOnly)
	self.vy = self.vy + GRAVITY
	self:floatPhysics(boundsOnly)
end

function Sprite:floatPhysics(boundsOnly)
	-- calculate number of physics steps needed
	local xGridSpeed = ceil(abs(self.vx))
	local yGridSpeed = ceil(abs(self.vy))
	local segments = max(xGridSpeed, yGridSpeed)
	
	-- reset physics flags
	self.collideSide = false
	self.onGround = self.onGround and self.vy == 0
	self.hitCeiling = false
	
	-- run physics
	for i = 1,segments do
		self:physicsStep(segments, boundsOnly)
	end
end
function Sprite:physicsStep(fraction, boundsOnly)
	-- moves sprite & checks for world collisions,
	-- resetting location if so; collision is based
	-- on corners
	-- fraction: splits velocity into multiple iterations for fast objects
	-- boundsOnly: don't test againt grid tiles, just roomBounds
	local myRoom = self.room
	local w,h = self.w, self.h
	
	local lastX = self.x
	local lastY = self.y
	
	local x = self.x + self.vx / fraction
	local y = self.y + self.vy / fraction
	
	-- get cells
	local gLastX = floor(lastX)
	local gLastY = floor(lastY)
	local gx = floor(x)
	local gy = floor(y)
	
	-- check potential collisions (if any cell borders were crossed)
	local function collideWorldCheck(_, gx, gy)
		local inRoom
		for _, room in pairs(rooms) do

			-- convert to room coords
			local lgx = gx + myRoom.x - room.x
			local lgy = gy + myRoom.y - room.y

			-- test if point inside a given room
			if lgx >= 0 and lgx < room.w
			and lgy >= 0 and lgy < room.h then
			
				if boundsOnly then return false, room end
				
				-- test against room's tiles
				
				local tile = room:getGrid(lgx, lgy)
				if tile == nil then print(lgx, lgy, gy) end
				return tile.solid
			end
		end

		-- outside all rooms
		return true

	end

	-- falling
	if gy < gLastY then
		if collideWorldCheck(room, gx, gy)
		or collideWorldCheck(room, gx + w, gy) then
			--hit ground
			self.onGround = true
			--bump up to edge of surface
			y = gLastY
			gy = gLastY
			self.vy = 0
		end
	end

	-- jumping/flying up
	if gy > gLastY then
		if collideWorldCheck(room, gx, gy + h)
		or collideWorldCheck(room, gx + w, gy + h) then
			--hit ceiling
			self.hitCeiling = true
			--bump down to edge of surface
			y = gLastY + 0.999
			gy = gLastY
			self.vy = 0
		end
	end
	
	-- left
	if gx < gLastX then
		if collideWorldCheck(room, gx, gy)
		or collideWorldCheck(room, gx, gy + h) then
			--hit wall
			self.collideSide = true
			--bump over to edge of surface
			x = gLastX
			gx = gLastX
			self.vx = 0
		end
	end

	-- right
	if gx > gLastX then
		if collideWorldCheck(room, gx + w, gy)
		or collideWorldCheck(room, gx + w, gy + h) then
			--hit wall
			self.collideSide = true
			--bump over to edge of surface
			x = gLastX + 0.999
			gx = gLastX
			self.vx = 0
		end
	end

	-- set position
	self.x = x
	self.y = y
	
	-- jump rooms if appropriate
	boundsOnly = true
	local _, centerRoom = collideWorldCheck(nil, gx + w/2, gy + h/2)
	if centerRoom ~= myRoom then
		--print("jump", self.x, self.y)
		centerRoom:add(self)
		--print("", self.x, self.y)
	end
	
end

----------------------------------------------- "brain" Coroutine Functions

function Sprite:wrap(func)
	return coroutine.wrap(func)
end
function Sprite:wrapLoop(func)
	return coroutine.wrap(function()
		while true do
			func()
		end
	end)
end
function Sprite:yield()
	coroutine.yield()
	return true
end
function Sprite:waitFrames(n)
	for i = 1,n do
		coroutine.yield()
	end
end

--------------------------------------------------------------------- Rooms

-- spritesheet indicies
local function tile(index, solid)
	if solid == nil then solid = true end
	return {
		index = index,
		solid = solid,
	}
end

SOLID = tile(1)
FLAT = tile(2)
LEDGE_RIGHT = tile(3)
LEDGE_LEFT = tile(4)
BLANK = tile(6, false)
PLAT_LEFT = tile(7)
PLAT_RIGHT = tile(8)
PLAT = tile(9)
M = tile(10, false)
STONE_LEFT = tile(11)
STONE = tile(12)
FLAT_STONE = tile(13)
CORNER_RIGHT = tile(14)
STONE_RIGHT = tile(16)
CORNER_BOTTOM_LEFT = tile(17)
BOTTOM = tile(18)
CORNER_BOTTOM_RIGHT = tile(19)
CORNER_LEFT = tile(20)

Room = Class()

function Room:init(w, h, sheet)
	self.w = w
	self.h = h
	self.sheet = sheet
	
	self.grid = {}
	self.sprites = {}
	
	self.x = 0
	self.y = 0
end

function Room:add(obj)

	-- coordinate offsets
	local dx, dy = 0,0
	
	local oldRoom = obj.room
	if oldRoom then
		dx = oldRoom.x - self.x
		dy = oldRoom.y - self.y
		oldRoom:remove(obj)
	end
	
	obj.room = self
	obj.x = obj.x + dx
	obj.y = obj.y + dy
	
	self.sprites[obj] = obj
end
function Room:remove(obj)
	self.sprites[obj] = nil
end

function Room:setGrid(x,y, tile)
	local index = y*self.w + x
	self.grid[index] = tile
end
function Room:getGrid(x,y)
	local index = y*self.w + x
	return self.grid[index]
end

function Room:tick(timeDiff)
	
	for sprite in pairs(self.sprites) do
		sprite:tick(timeDiff)
	end
	
end

function Room:renderBg(x,y)
	beginSprites(x,y)

	for x = 0, self.w-1 do
		for y = 0, self.h-1 do
			local tile = self:getGrid(x,y)
			if tile then
				self.sheet:draw(x,y, tile.index)
			end
		end
	end
	
	endSprites()
end
function Room:renderSprites(x,y)
	beginSprites(x,y)
	
	for sprite in pairs(self.sprites) do
		sprite:render()
	end
	
	endSprites()
end
function Room:render()

end

return _ENV

