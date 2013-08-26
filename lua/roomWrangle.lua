
local pairs, print = pairs, print
local content = require "content"
local sprite = require "sprite"
local world = require "world"

local SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT

local _ENV = {}

Camera = world.Sprite(0,0, 1, content.GreenTiles)

Camera.solid = false

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

		self:gravityPhysics(true) -- only check against world bounds
		--print(self.x, self.y, self.vx, self.vy, self.w, self.room.w)
	
	end
end

function Camera:render()
end

function Camera:renderView()
	local myRoom = self.room
	--print(self.x, self.y)
	
	local dx, dy = self.x + myRoom.x, self.y + myRoom.y
	--print(dx, dy)

	for _, room in pairs(world.rooms) do
		room:renderBg(dx - room.x, dy - room.y)
	end
	for _, room in pairs(world.rooms) do
		room:renderSprites(dx - room.x, dy - room.y)
	end
end

FlagSheet = sprite.SpriteSheet("gl/flag.png", 3, 2)
Flag = world.Sprite(0,0, 1, FlagSheet)

function Flag:brain()

	repeat self:yield() until self:intersect(world.hero)

	-- add 10 seconds to clock
	world.timer = world.timer + 10000
	print("time", world.timer)

	self.frame = 2
	
	local newRoom = self.nextRoom(world.timer / 1000)
	newRoom.x = 0 --self.room.x + self.room.w
	newRoom.y = 0 --self.y - 2
	
	self.room.x = -self.room.w
	self.room.y = 0 -- -self.y + 2
	
	world.rooms = {self.room, newRoom}

	while true do self:yield() end

end

return _ENV

