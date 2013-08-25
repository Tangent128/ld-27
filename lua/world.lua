
local setmetatable, pairs = setmetatable, pairs

local _ENV = {}

room_mt = {}
room_mt.__index = room_mt

function makeRoom(w, h)
	local room = setmetatable({}, room_mt)
	
	room.w = w
	room.h = h
	
	room.grid = {}
	room.sprites = {}
	
	return room
end

function room_mt:setGrid(x,y, obj)
	local index = y*self.width + x
	self.grid[index] = obj
end
function room_mt:getGrid(x,y)
	local index = y*self.width + x
	return self.grid[index]
end

function room_mt:render()
	
	for sprite in pairs(self.sprites) do
		sprite:render()
	end
	
end

return _ENV

