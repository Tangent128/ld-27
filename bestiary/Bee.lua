
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
		
        local diffx = self.x - hx
        local diffy = self.y - hy
        local magnitude = ( (diffx^2) +(diffy^2))^0.5 
	
	if magnitude <= 0.001 then magnitude = 0.001 end
	
        local velx = diffx * speed / magnitude
        local vely = diffy * speed / magnitude

		self.vx = -velx 
		
		self:floatPhysics()
		
		if self.collideSide then
			self.flip = not self.flip
            self.vx = velx
		end

        if (diffx < 0 and self.flip == false) then
            self.flip = true
        end
        
        if (diffx > 0 and self.flip == true) then
            self.flip = false
        end

        if self.onGround or self.hitCeiling then
			vertBump = true
		end

        self.vy = vertBump and vely or -vely + 0.1

        --print (velx, vely)

        --print (hx, hy, diffx, diffy)

	end
end

return Bee

