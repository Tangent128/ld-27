local sprite = require "sprite"
local world = require "world"

local ProjSheet = sprite.SpriteSheet("gl/Projectiles.png", 1,4);
local Projectile = world.Sprite(0,0, 1, ProjSheet)

Projectile.solid = false

function Projectile:brain()

    local impact = false

    --Assume velocity is fixed, set by brain of other objects. Along with frame number

	while self:yield() do
		self:floatPhysics()

        if impact == true then
            self:die()
        end

	for obj in self:loopAllSprites() do
		if self:intersect(obj) then
			if obj ~= self.owner then
				impact = true
				print("hit", obj.sheet.filename)
			
				-- objects may define an optional :getShot(bullet) method
				if obj.getShot then obj:getShot(self) end
			end
		end
	end

        if self.collideSide or self.onGround or self.hitCeiling then
            --Set to impact frame
			self.frame = 4 
            self.vx = 0
            self.vy = 0
            impact = true
		end

	end
end

return Projectile

