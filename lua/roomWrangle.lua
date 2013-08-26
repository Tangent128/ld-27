
local pairs, print = pairs, print
local content = require "content"
local world = require "world"

local SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT

local _ENV = {}

Camera = world.Sprite(0,0, 1, content.GreenTiles)

-- override normal size with screen bounds
Camera.w = SCREEN_WIDTH
Camera.h = SCREEN_HEIGHT

function Camera:init()
	
end

function Camera:brain()
	
	while self:yield() do
	
		self:floatPhysics(true) -- only check against world bounds
	
	end
end

function Camera:render()
end

function Camera:renderView()
	local dx, dy = self.x, self.y

	for _, room in pairs(world.rooms) do
		room:renderBg(room.x, room.y)
	end
	for _, room in pairs(world.rooms) do
		room:renderSprites(room.x, room.y)
	end
end

return _ENV

