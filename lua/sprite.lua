
local setmetatable, pairs, print = setmetatable, pairs, print
local Class = require "object".Class

local makeTexture, drawSprite = g.makeTexture, g.drawSprite
local beginSprites, endSprites = g.beginSprites, g.endSprites

local SCREEN_WIDTH, SCREEN_HEIGHT = SCREEN_WIDTH, SCREEN_HEIGHT

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

function SpriteSheet:fullscreen(frame)
	beginSprites(0,0)
	drawSprite(0,0, self.texture, SCREEN_WIDTH, SCREEN_HEIGHT, frame or 1, self.count, false)
	endSprites()
end

return _ENV

