
local setmetatable, pairs, print = setmetatable, pairs, print
local coroutine = coroutine
local Class = require "object".Class
local _ENV = {}

------------------------------------------------------------ Sprite Objects

Sprite = Class()

function Sprite:init(x, y, frame, sheet)
	-- sheet can be inherited from prototype
	self.sheet = sheet

	--current frame
	self.frame = frame

	--location
	self.x = x or 0
	self.y = y or 0
	
	-- bounds
	self.w = self.sheet.scale
	self.h = self.sheet.scale
	
	self.flip = false
	
	if self.brain then
		self.tick = self:wrap(self.brain)
	end
end

function Sprite:fall()
	
end

function Sprite:collide()
	self.lastX = self.x
	self.lasty = self.y
end

function Sprite:tick(timeDiff)
end

function Sprite:render()
	self.sheet:draw(self.x, self.y, self.frame, self.flip)
end

-- for use in "brain" coroutines

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
SOLID = 1
FLAT = 2
LEDGE_RIGHT = 3
LEDGE_LEFT = 4
BLANK = 6
PLAT_LEFT = 7
PLAT_RIGHT = 8
PLAT = 9
STONE_LEFT = 10
STONE = 11
FLAT_STONE = 12
CORNER_RIGHT = 13
STONE_RIGHT = 15
CORNER_BOTTOM_LEFT = 16
BOTTOM = 17
CORNER_BOTTOM_RIGHT = 18
CORNER_LEFT = 19

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
				self.sheet:draw(x,y, tile)
			end
		end
	end
	
	for sprite in pairs(self.sprites) do
		sprite:render()
	end
	
end

return _ENV

