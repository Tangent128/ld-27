
package.path = "lua/?.lua" --";bestiary/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true, default = "10seconds.png"},
}

sprite = require "sprite"
local SpriteSheet = sprite.SpriteSheet

-- dummy sprite
local sprite1 = g.makeTexture("10seconds.png");
local Bee = SpriteSheet("bestiary/BeeSheet.png", 2, 2)
local Sheep = SpriteSheet("bestiary/SheepSheet.png", 1,3);
local sprite4 = g.makeTexture("Conehead3.png");
local sprite5 = g.makeTexture("Sheep.png");

local beat = 0;
local mouse = {}

function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	mouse.x = mx
	mouse.y = my

	tick(time)
	render()
	Sheep:draw(0,0)
	--g.drawSprite(19,14,sprite5)
	--g.drawSprite(mx-1,my-1,sprite4)
    --g.drawSprite(xCur,yCur,sprite3)
end

function tick(time)
	beat = ( time % 200 ) > 100
end

function render()
	Bee:draw(mouse.x, mouse.y)
	Bee:draw(mouse.x - 2, mouse.y, 2)
	Bee:draw(mouse.x - 1, mouse.y - 2, beat and 1 or 2, true)
end

