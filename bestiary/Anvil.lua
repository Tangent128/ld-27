
local sprite = require "sprite"
local world = require "world"

local Projectile = require "Projectile"

local AnvilSheet = sprite.SpriteSheet("bestiary/FlyingAnvilSheet.png", 2,2);
local Anvil = world.Sprite(0,0, 1, AnvilSheet)

function Anvil:brain()
	
	local falling = true

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
		boolet.vx = -1.0
		boolet.vy = 0
        boolet.frame = 2
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

	while self:yield() do
		animate()
		gun()
		  
		if falling then
			self:gravityPhysics()
		else
			self.vy = 0.2
			self:floatPhysics()
		end

		if self.onGround then
			falling = false
		end

		if self.hitCeiling then
			falling = true
		end

	end
end

return Anvil

