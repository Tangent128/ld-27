
local sprite = require "sprite"
local world = require "world"

local SheepSheet = sprite.SpriteSheet("bestiary/SheepSheet.png", 2,3);
local Sheep = world.Sprite(0,0, 1, SheepSheet)

function Sheep:brain()
	
	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 3 then
			self.frame = 1
		end
	end)
	
	local speed = 0.1875
	
	while self:yield() do
		animate()
		
		speed = math.min(speed + 0.02, 2.0)
		
		self.vx = self.flip and speed or -speed
		
		self:gravityPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
			speed = 0.1875
		end
		
		if self:intersect(world.hero) then
			print "BAAAAA!"
		end
		
	end
end

return Sheep

