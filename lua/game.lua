
TILE_SIZE = 32
SCREEN_WIDTH = 640 / TILE_SIZE
SCREEN_HEIGHT = 480 / TILE_SIZE

FRAME_LENGTH = 30

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
	anvilGun = {},
	testSprite = {arg = true},
	time = {arg = true},
}

world = require "world"
content = require "content"
roomGen = require "roomGen"
roomWrangle = require "roomWrangle"

-- init world

world.poof = content.Puffball

local function initWorld(...)

	world.hero = content.Hero(3,3)
	world.camera = roomWrangle.Camera()
	world.timer = 10000

	room = roomGen.makeDebugRoom(SCREEN_WIDTH+1, SCREEN_HEIGHT + 10)
	room:add(world.hero)
	room:add(world.camera)

	world.rooms = {room}

	if args.testSprite then
		room:add(content[args.testSprite](SCREEN_WIDTH - 5,5))
		world.timer = 10000
	end
	
	if args.time then
		world.timer = tonumber(args.time)
	end

	paused = true
	title = true
	lost = false

end
clicked = false

initWorld()

-- Lua side of game loop
function gameCycle(time, mX, mY, mLeft, kU, kD, kL, kR, kSpace, kEscape)
	verboseFailure(function() -- get useful error traceback

		-- Input
		
		if kEscape then
			paused = true
		end

		if kSpace then
			-- only run on up->down transition, not every cycle space is down
			if not clicked then
				paused = false
				title = false
				clicked = true
			
				if lost then
					initWorld()
					title = true
				end
			end
		else
			clicked = false
		end
		--print(mLeft and "down" or "up", clicked and "click")

		if not paused then
			world.hero:input(mX, mY, kU, kD, kL, kR, kSpace, kEscape)
		end
		
		-- Tick
		if world.timer <= 0 then
			paused = true
			lost = true
		end
		
		if not paused then
			tick(time)
		end
		
		-- Render
		render()

	end)
end

function tick(time)
	
	-- tick for each room
	for _, room in pairs(world.rooms) do
		room:tick(timeDiff)
	end
	
	-- Time Advance
	world.timer = world.timer - FRAME_LENGTH
end

function render(mx, my)
	
	world.camera:renderView()
	
	renderClock()
	
	-- overlays
	if paused then
		
		if lost then
			content.GameOver:fullscreen()
		elseif title then
			content.StartScreen:fullscreen()
		else
			content.PauseScreen:fullscreen()
		end
		
		-- cursor?
		--content.???:draw(mx, my)
	end
end

local digits = content.ClockTiles
local cx = SCREEN_WIDTH/2 - 1.5
local cy = SCREEN_HEIGHT - 3
function renderClock()
	local t = math.floor(world.timer / 1000)
	t = math.min(t, 99)
	
	local ones = t % 10
	local tens = (t - ones) / 10

	-- account for tile orders
	if ones == 0 then ones = 10 end
	if tens == 0 then tens = 10 end
	
	g.beginSprites(0,0)
		digits:draw(cx,cy,11)
		digits:draw(cx-1,cy,tens)
		digits:draw(cx+1,cy,ones)
	g.endSprites()	
end

end, ...)

