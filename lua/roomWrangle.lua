
local pairs, print = pairs, print
local content = require "content"
local world = require "world"

local SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT

local _ENV = {}

Camera = world.Sprite(0,0, 1, content.GreenTiles)

-- override normal size with screen bounds
function Camera:init(...)
	world.Sprite.init(self, ...)
	
	self.w = SCREEN_WIDTH
	self.h = SCREEN_HEIGHT
end

function Camera:brain()
	
--	self.y = 5
--	self.x = 10
--	self.vx = -0.1
	local cw = self.w / 2
	local ch = self.h / 2

	while self:yield() do
	
		local hx, hy = self:locateHero()
		
		local dx = hx - self.x - cw
		local dy = hy - self.y - ch

		-- springy cam, average offsets into it instead of setting
		self.vx = (self.vx*3 + dx) / 4
		self.vy = (self.vy*3 + dy) / 4

world.d = true
		self:gravityPhysics(true) -- only check against world bounds
world.d = false
		--print(self.x, self.y, self.vx, self.vy, self.w, self.room.w)
	
	end
end

function Camera:render()
end

function Camera:renderView()
	local myRoom = self.room
	local dx, dy = self.x - myRoom.x, self.y - myRoom.y

	for _, room in pairs(world.rooms) do
		room:renderBg(dx - room.x, dy - room.y)
	end
	for _, room in pairs(world.rooms) do
		room:renderSprites(dx - room.x, dy - room.y)
	end
end

return _ENV

