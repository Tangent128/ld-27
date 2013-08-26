
local sprite = require "sprite"
local world = require "world"

local BeeSheet = sprite.SpriteSheet("bestiary/BeeSheet.png", 2,2);
local Bee = world.Sprite(0,0, 1, BeeSheet)

Bee.hostile = true

function Bee:getShot(bullet)
	if not bullet.hostile then
		--and bullet.y < self.y + 1
		self:explode()
	end
end

function Bee:brain()

	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
	end)
	
	local speed = 0.1875

	while self:yield() do
		animate()
		
        local vertBump = false

        local hx, hy = self:locateHero()
		
        self.vx = hx - self.x
        self.vy = hy - self.y

	self:normalizeSpeed(speed, 0)
		
	self:floatPhysics()

        if (self.vx > 0.1) then
            self.flip = true
        end
        
        if (self.vx < -0.1) then
            self.flip = false
        end

        if self.onGround or self.hitCeiling then
			vertBump = true
		end

		if vertBump then
			self.vy = -self.vy
		end
		--= vertBump and vely or -vely + 0.1

        --print (velx, vely)

        --print (hx, hy, diffx, diffy)

        if self:intersect(world.hero) then
			--print "BZZZZT!"
			if world.hero.getShot then 
                world.hero:getShot(self)
            end
		end

	end
end

return Bee

