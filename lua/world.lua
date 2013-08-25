
local setmetatable, pairs = setmetatable, pairs
local Class = require "object".Class
local _ENV = {}

Sprite = Class()

function Sprite:init(sheet)
	self.sheet = sheet
	self.w = sheet.scale
	self.h = sheet.scale
end

function Sprite:fall()
	
end

Room = Class()

function Room:init(w, h)
	self.w = w
	self.h = h
	
	self.grid = {}
	self.sprites = {}
end

function Room:setGrid(x,y, obj)
	local index = y*self.width + x
	self.grid[index] = obj
end
function Room:getGrid(x,y)
	local index = y*self.width + x
	return self.grid[index]
end

function Room:render()
	
	for sprite in pairs(self.sprites) do
		sprite:render()
	end
	
end

return _ENV

