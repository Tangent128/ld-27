
-- make error messages more verbose
local function verboseFailure(body)
	local ok, err = xpcall(body, function(err)
		return debug.traceback(err, 2)
	end)
	if not ok then
		error(err)
	end
end

verboseFailure(function(...)

package.path = "lua/?.lua" --";bestiary/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true, default = "10seconds.png"},
}

world = require "world"
content = require "content"
roomGen = require "roomGen"

local beat = 0;
local mouse = {}

room = roomGen.makeDebugRoom(15,15)

function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	verboseFailure(function() -- get useful error traceback
		
		mouse.x = mx
		mouse.y = my

		tick(time)
		render()
		
	end)
end

function tick(time)
	beat = ( time % 200 ) > 100
end

function render()
	room:render()
	content.BeeSheet:draw(mouse.x, mouse.y)
	content.BeeSheet:draw(mouse.x - 2, mouse.y, 2)
	content.BeeSheet:draw(mouse.x - 1, mouse.y - 2, beat and 1 or 2, true)
end

end, ...)

