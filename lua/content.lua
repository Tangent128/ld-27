
local sprite = require "sprite"
local world = require "world"

local package = package

local SpriteSheet = sprite.SpriteSheet
local Sprite = world.Sprite

local _ENV = {}

-------------------------------------------------------------- SpriteSheets

GreenTiles = SpriteSheet("gl/tilesetStrip.png", 1, 20)

------------------------------------------------------------------ Bestiary?

local lpath = package.path
package.path = "bestiary/?.lua"

BeeSheet = SpriteSheet("bestiary/BeeSheet.png", 2, 2)
Bee = Sprite(0,0, 1, BeeSheet)

SheepSheet = SpriteSheet("bestiary/SheepSheet.png", 1,3);
Sheep = Sprite(0,0, 1, SheepSheet)

package.path = lpath

return _ENV

