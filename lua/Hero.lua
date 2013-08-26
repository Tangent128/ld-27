
local sprite = require "sprite"
local world = require "world"

local Projectile = require "Projectile"

local HeroSheet = sprite.SpriteSheet("gl/ProtagSheet.png", 2,6);
local Hero = world.Sprite(0,0, 1, HeroSheet)

function Hero:input(mx, my, kU, kD, kL, kR, kSpace, kEscape)
	
	local kx, ky = 0, 0
	
    self.wantToFire = False

	if kU then ky = ky + 1 end
	if kD then ky = ky - 1 end
	
	if kL then
		kx = kx - 1
		self.flip = true
	end
	if kR then
		kx = kx + 1
		self.flip = false
	end
	
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
    
    self.wantToFire = kSpace

	
end

function Hero:getHit(vx, vy)
	-- fling upward
	self.onGround = false

	self.vx = math.min(vx, 0) -- fling backwards, but never forwards
	self.vy = math.abs(vx) -- fling w/ bullet's horizontal force
end

function Hero:getShot(bullet)
	if bullet.hostile then
		
		self:getHit(bullet.vx, bullet.vy)
		
	end
end

function Hero:brain()

	local gun = self:wrapLoop(function()
	
		repeat self:yield() until self.wantToFire
		
		local boolet = Projectile(0,0)
		
		boolet.vx = 1.0
		boolet.vy = 0
		boolet.frame = 1
		boolet.owner = self
		boolet.hostile = true
		
		self:spawn(1,0, boolet)
		
		--cooldown
		self:waitFrames(5)
	end)
	
	local animate = self:wrapLoop(function()
		self:waitFrames(10) -- yields 10 times then returns
	
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
		
		self.frame = 1
	end)
	
	while self:yield() do
		animate()
		gun()

		self:gravityPhysics()
		
	end
end

return Hero

