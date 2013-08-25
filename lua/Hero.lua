
local sprite = require "sprite"
local world = require "world"

local HeroSheet = sprite.SpriteSheet("bestiary/ConeheadSheet.png", 2,3);
local Hero = world.Sprite(0,0, 1, HeroSheet)

function Hero:brain()
	
	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
	end)
	
	while self:yield() do
		animate()
		
		--speed = speed + 0.01
		
		--self.vx = self.flip and speed or -speed
		
		self:gravityPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
		end
		
	end
end

return Hero

