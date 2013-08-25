
TILE_SIZE = 32
SCREEN_WIDTH = 640 / TILE_SIZE
SCREEN_HEIGHT = 480 / TILE_SIZE


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
}

world = require "world"
content = require "content"
roomGen = require "roomGen"

room = roomGen.makeDebugRoom(SCREEN_WIDTH, SCREEN_HEIGHT)
hero = content.Hero(3,3)
room:add(hero)

if args.testSprite then
	room:add(content[args.testSprite](SCREEN_WIDTH - 4,5))
end

-- Lua side of game loop
function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	verboseFailure(function() -- get useful error traceback
		
		hero:input(mx, my, kU, kD, kL, kR, kSpace, kEscape)

		tick(time)
		
		render()
		
	end)
end

function tick(time)
	-- frame length
	local timeDiff = 30
	
	hero.room:tick(timeDiff)
end

function render(mx, my)
	hero.room:render()
	
	-- cursor
	--content.???:draw(mx, my)
end

end, ...)

