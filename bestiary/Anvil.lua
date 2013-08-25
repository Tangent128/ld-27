
local sprite = require "sprite"
local world = require "world"

AnvilSheet = sprite.SpriteSheet("bestiary/FlyingAnvilSheet.png", 2,2);
Anvil = world.Sprite(0,0, 1, AnvilSheet)

function Anvil:brain()
	
    local switch = 0
    local falling = 0

	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
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
        
        if switch == 0 then
		
            self:gravityPhysics()
		
        end
        
        if switch == 1 then

            self:floatPhysics()
        
            self.vy = 0.2
        
        end
        
        if self.onGround and falling == 0 then
            switch = (switch + 1) % 2
            falling = (falling + 1) % 2
            print "onGround"
        end
        
        if self.hitCeiling and falling == 1 then
            switch = (switch + 1) % 2
            falling = (falling + 1) % 2
        end
		
	end
end

return Anvil

