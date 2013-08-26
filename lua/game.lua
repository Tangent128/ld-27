
TILE_SIZE = 32
SCREEN_WIDTH = 640 / TILE_SIZE
SCREEN_HEIGHT = 480 / TILE_SIZE

--SCREEN_WIDTH = 8
--SCREEN_HEIGHT = 5

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
roomWrangle = require "roomWrangle"

-- init world
world.hero = content.Hero(3,3)
world.camera = roomWrangle.Camera()

room = roomGen.makeDebugRoom(SCREEN_WIDTH+1, SCREEN_HEIGHT + 5)
room2 = roomGen.makeDebugRoom2(SCREEN_WIDTH+1, SCREEN_HEIGHT + 5)
room2.x = SCREEN_WIDTH+1
room:add(world.hero)
room:add(world.camera)

world.rooms = {room, room2}

if args.testSprite then
	room:add(content[args.testSprite](SCREEN_WIDTH - 4,5))
end

paused = false

-- Lua side of game loop
function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
	verboseFailure(function() -- get useful error traceback
		
		if not paused then
			world.hero:input(mx, my, kU, kD, kL, kR, kSpace, kEscape)

			tick(time)
		else
			--something
		end
		
		render()
		
	end)
end

function tick(time)
	-- frame length
	local timeDiff = 30
	
	for _, room in pairs(world.rooms) do
		room:tick(timeDiff)
	end
end

function render(mx, my)
	
	world.camera:renderView()
	
	-- cursor
	if paused then
	--content.???:draw(mx, my)
	end
end

end, ...)

