
local sprite = require "sprite"
local world = require "world"

local BeeSheet = sprite.SpriteSheet("bestiary/BeeSheet.png", 2,2);
local Bee = world.Sprite(0,0, 1, BeeSheet)

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
        
        local magnitude = ( (self.vx^2) +(self.vy^2))^0.5 
	
	if magnitude <= 0.001 then magnitude = 0.001 end
	
        self.vx = self.vx * speed / magnitude
        self.vy = self.vy * speed / magnitude
		
	self:floatPhysics()

        if (self.vx > 0) then
            self.flip = true
        end
        
        if (self.vx < 0) then
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

	end
end

return Bee

