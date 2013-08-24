
package.path = "lua/?.lua" --";bestiary/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true, default = "10seconds.png"},
}

function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	tick()
	render()
end

function tick()
end

function render()
	
end

