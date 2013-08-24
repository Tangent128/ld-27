
package.path = "lua/?.lua" --";bestiary/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true, default = "10seconds.png"},
}

-- dummy sprite
local sprite = g.makeTexture("10seconds.png");

function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	tick()
	render()
	g.drawSprite(0,0,sprite)
	g.drawSprite(19,14,sprite)
	g.drawSprite(mx,my,sprite)
	g.drawSprite(mx-1,my-1,sprite)
end

function tick()
end

function render()
	
end

