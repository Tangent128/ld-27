
local sprite = require "sprite"
local world = require "world"

local Projectile = require "Projectile"

local AnvilSheet = sprite.SpriteSheet("bestiary/FlyingAnvilSheet.png", 2,2);
local Anvil = world.Sprite(0,0, 1, AnvilSheet)

Anvil.hostile = true
Anvil.hp = 3

function Anvil:getShot(bullet)
	if not bullet.hostile then
		--and bullet.y < self.y + 1
        self.hp = self.hp - 1
        if self.hp <= 0 then
            self:explode()
        end
	end
end

local args = args

function Anvil:brain()
	

	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
	end)
	local gun = self:wrapLoop(function()
		self:waitFrames(20) -- wait ~2/3 seconds

		local boolet = Projectile(0,0)
		local hx, hy = self:locateHero()
		boolet.vx = hx - self.x
		boolet:normalizeSpeed(1.0)
        boolet.frame = 2
        boolet.owner = self
        boolet.hostile = true
		self:spawn(-1,0, boolet)
	end)
		
	local speed = 0.1875

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

	local falling = true
	local riseTo = 0

	while self:yield() do
		animate()
		if args.anvilGun then
			gun()
		end
		  
		if falling then
			self:gravityPhysics()
			
			if self:intersect(world.hero) then
				if world.hero.getHit then world.hero:getHit(-1.5, 1.0) end
			end
			
		else
			self.vy = 0.2
			self:floatPhysics()
			
			if self.y >= riseTo then
				falling = true
			end
		end

		if self.onGround then
			falling = false
			riseTo = self.y + 10
		end

		if self.hitCeiling then
			falling = true
		end

	end
end

return Anvil

