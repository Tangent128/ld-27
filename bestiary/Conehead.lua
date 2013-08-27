
local sprite = require "sprite"
local world = require "world"

local Projectile = require "Projectile"

local ConeheadSheet = sprite.SpriteSheet("bestiary/ConeheadSheet.png", 1,3);
local Conehead = world.Sprite(0,0, 1, ConeheadSheet)

Conehead.hostile = true

function Conehead:getShot(bullet)
	if not bullet.hostile then
		--and bullet.y < self.y + 1
		self:explode()
	end
end

function Conehead:brain()
	
	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 3 then
			self.frame = 1
		end
	end)
	local gun = self:wrapLoop(function()
		self:waitFrames(15) -- wait ~2/3 seconds

		local boolet = Projectile(0,0)
		local hx, hy = self:locateHero()
		boolet.vx = hx - self.x
		boolet:normalizeSpeed(1.0)
        boolet.frame = 2
        boolet.owner = self
        boolet.hostile = true
		self:spawn(-1,0, boolet)
	end)

	local speed = 0.05
	
	while self:yield() do
		animate()
		gun()

		speed = math.min(speed, 2.0)
		
		self.vx = self.flip and speed or -speed
		
		self:gravityPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
			speed = 0.05
		end
		
		if self:intersect(world.hero) then
			--print "$VUVUZELA_NOISE!"
			if world.hero.getShot then world.hero:getShot(self) end
		end
		
	end
end

return Conehead

