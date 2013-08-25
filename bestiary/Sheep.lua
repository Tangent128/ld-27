
local sprite = require "sprite"
local world = require "world"

SheepSheet = sprite.SpriteSheet("bestiary/SheepSheet.png", 2,3);
Sheep = world.Sprite(0,0, 1, SheepSheet)

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
		
		speed = speed + 0.01
		
		self.vx = self.flip and speed or -speed
		
		self:gravityPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
		end
		
	end
end

return Sheep

