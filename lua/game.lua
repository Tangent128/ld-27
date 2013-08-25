

-- make error messages more verbose
local function verboseFailure(body, ...)
	local ok, err = xpcall(body, function(err)
		return debug.traceback(err, 2)
	end, ...)
	if not ok then
		error(err)
	end
end

verboseFailure(function(...)

package.path = "lua/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true},
--	testSprite = {arg = true, default = "Sheep"},
}

world = require "world"
content = require "content"
roomGen = require "roomGen"

local beat = 0;
local mouse = {}

room = roomGen.makeDebugRoom(15,15)

if args.testSprite then
	room:add(content[args.testSprite](8,5))
end

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
	
	-- frame length
	local timeDiff = 30
	
	room:tick(timeDiff)
end

function render()
	room:render()
	content.BeeSheet:draw(mouse.x, mouse.y)
	content.BeeSheet:draw(mouse.x - 2, mouse.y, 2)
	content.BeeSheet:draw(mouse.x - 1, mouse.y - 2, beat and 1 or 2, true)
end

end, ...)

