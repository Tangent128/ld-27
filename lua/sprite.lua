
local setmetatable, pairs, print = setmetatable, pairs, print
local Class = require "object".Class
local makeTexture, drawSprite = g.makeTexture, g.drawSprite

local _ENV = {}

SpriteSheet = Class()

textureCache = {}

function grabTexture(filename)
	local texture = textureCache[filename]
	
	if not texture then
		texture = makeTexture(filename)
	end
	
	return texture
end

function SpriteSheet:init(filename, scale, count)
	self.texture = grabTexture(filename)
	self.scale = scale or 1
	self.count = count or 1
end

function SpriteSheet:draw(x, y, frame, flip)
	drawSprite(x,y, self.texture, self.scale, self.scale, frame or 1, self.count, flip or false)
end

return _ENV

