
local sprite = require "sprite"
local world = require "world"

local PuffSheet = sprite.SpriteSheet("gl/CloudSheet.png", 2,3);
local Puffball = world.Sprite(0,0, 1, PuffSheet)

Puffball.solid = false

function Puffball:brain()

	for i = 1,3 do
		self.frame = i
		self:waitFrames(2)
	end
	
	self:die()		
end

return Puffball

