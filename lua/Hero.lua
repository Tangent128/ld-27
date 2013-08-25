
local sprite = require "sprite"
local world = require "world"

local HeroSheet = sprite.SpriteSheet("bestiary/ConeheadSheet.png", 2,3);
local Hero = world.Sprite(0,0, 1, HeroSheet)

function Hero:input(mx, my, kU, kD, kL, kR, kSpace, kEscape)
	
	local kx, ky = 0, 0
	
	if kU then ky = ky + 1 end
	if kD then ky = ky - 1 end
	
	if kL then kx = kx - 1 end
	if kR then kx = kx + 1 end
	
	if self.onGround then
		self.vx = kx * 0.2
		
		if kU then
			self.vy = 1.0
		end
	else
		local newVx = self.vx + kx * 0.02
		if math.abs(newVx) <= 0.2 then
			self.vx = newVx
		end
	end
	
end

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

