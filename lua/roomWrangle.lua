
local pairs, print = pairs, print
local content = require "content"
local world = require "world"

local SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT

local _ENV = {}

Camera = world.Sprite(0,0, 1, content.GreenTiles)

-- override normal size with screen bounds
Camera.w = SCREEN_WIDTH
Camera.h = SCREEN_HEIGHT

function Camera:brain()
	
	self.y = 0
	self.x = 1
	self.vx = 0.1

	while self:yield() do
	
		local hx, hy = self:locateHero()
	
		--[[while true do
			repeat 
				self:yield()
				self:gravityPhysics()
			until self.onGround
			repeat
				self:yield()
				self.vy = -0.2
				self:floatPhysics()
			until self.hitCeiling
		end]]
		
		self:floatPhysics(true) -- only check against world bounds
		--print(self.x, self.y, self.vx, self.vy)
	
	end
end

function Camera:render()
end

function Camera:renderView()
	local dx, dy = self.x, self.y

	for _, room in pairs(world.rooms) do
		room:renderBg(room.x + dx, room.y + dy)
	end
	for _, room in pairs(world.rooms) do
		room:renderSprites(room.x + dx, room.y + dy)
	end
end

return _ENV

