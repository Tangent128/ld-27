
local setmetatable, pairs, print = setmetatable, pairs, print
local floor, min, max = math.floor, math.min, math.max
local coroutine = coroutine
local Class = require "object".Class
local _ENV = {}

GRAVITY = -0.1

------------------------------------------------------------ Sprite Objects

Sprite = Class()

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

function Sprite:tick(timeDiff)
end

function Sprite:render()
	self.sheet:draw(self.x, self.y, self.frame, self.flip)
end

------------------------------------------------------------ Sprite Physics

function Sprite:gravityPhysics()
	self.vy = self.vy + GRAVITY
	self:floatPhysics()
end

local function collideWorldCheck(room, gx, gy)

	if gx < 0 or gx >= room.w then return true end
	if gy < 0 or gy >= room.h then return true end

	local tile = room:getGrid(gx, gy)
	return tile.solid
end
function Sprite:floatPhysics()
	-- calculate number of physics steps
	
	self:physicsStep(1)
end
function Sprite:physicsStep(fraction)
	-- moves sprite & checks for world collisions,
	-- resetting location if so; collision is based
	-- on corners. fraction allows multiple passes for fast objects
	local room = self.room
	local w,h = self.w, self.h
	
	local lastX = self.x
	local lastY = self.y
	
	local x = self.x + self.vx
	local y = self.y + self.vy
	
	self.collideSide = false
	self.onGround = self.onGround and self.vy <= 0
	self.hitCeiling = false
	
	-- get cells
	local gLastX = floor(lastX)
	local gLastY = floor(lastY)
	local gx = floor(x)
	local gy = floor(y)
	
	-- check potential collisions (if any cell borders were crossed)

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
			y = gLastY
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
			x = gLastX
			gx = gLastX
			self.vx = 0
		end
	end

	self.x = x
	self.y = y
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
STONE_LEFT = tile(10)
STONE = tile(11)
FLAT_STONE = tile(12)
CORNER_RIGHT = tile(13)
STONE_RIGHT = tile(15)
CORNER_BOTTOM_LEFT = tile(16)
BOTTOM = tile(17)
CORNER_BOTTOM_RIGHT = tile(18)
CORNER_LEFT = tile(19)

Room = Class()

function Room:init(w, h, sheet)
	self.w = w
	self.h = h
	self.sheet = sheet
	
	self.grid = {}
	self.sprites = {}
end

function Room:add(obj)

	if obj.room then
		obj.room:remove(obj)
	end
	
	obj.room = self
	
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

function Room:render()
	
	for x = 0, self.w-1 do
		for y = 0, self.h-1 do
			local tile = self:getGrid(x,y)
			if tile then
				self.sheet:draw(x,y, tile.index)
			end
		end
	end
	
	for sprite in pairs(self.sprites) do
		sprite:render()
	end
	
end

return _ENV

