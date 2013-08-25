
package.path = "lua/?.lua" --";bestiary/?.lua"

args = require "flags" {...} {
	debugRoom = {},
	testSprite = {arg = true, default = "10seconds.png"},
}

sprite = require "sprite"
local SpriteSheet = sprite.SpriteSheet

-- dummy sprite
local sprite1 = g.makeTexture("10seconds.png");
local Bee = SpriteSheet("bestiary/BeeSheet.png", 1, 2)
local sprite3 = g.makeTexture("Pitaya.png");
local sprite4 = g.makeTexture("Conehead3.png");
local sprite5 = g.makeTexture("Sheep.png");

xCiel = 20
yCiel = 15

xCur = 0
yCur = 0


function gameCycle(time, mx, my, kU, kD, kL, kR, kSpace, kEscape)
    xCur = (xCur + 0.5) % xCiel
    if xCur == 0 then
        yCur = (yCur + 0.5) % yCiel
    end
	tick()
	render()
	g.drawSprite(0,0,sprite1)
	g.drawSprite(19,14,sprite5)
	Bee:draw(mx,my)
	Bee:draw(mx-1,my)
	g.drawSprite(mx-1,my-1,sprite4)
    g.drawSprite(xCur,yCur,sprite3)
end

function tick()
end

function render()
	
end

