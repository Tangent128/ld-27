
local sprite = require "sprite"
local world = require "world"

local ClockSheet = sprite.SpriteSheet("bestiary/ClockSheet.png", 2,3);
local Clock = world.Sprite(0,0, 1, ClockSheet)

Clock.hostile = true

function Clock:getShot(bullet)
	if not bullet.hostile then
		--and bullet.y < self.y + 1
		self:explode()
        world.timer = world.timer + 10000
	end
end

function Clock:brain()
	
	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 3 then
			self.frame = 1
		end
	end)
	
	local speed = 0.10
	
	while self:yield() do
		animate()
		
		speed = math.min(speed + 0.02, 2.0)
		
		self.vx = self.flip and speed or -speed
		
		self:gravityPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
			speed = 0.10
		end
        
        if self.onGround then
            self.vy = 0.5
        end
		
		if self:intersect(world.hero) then
			print "RING!"
			if world.hero.getShot then world.hero:getShot(self) end
		end
		
	end
end

return Clock

