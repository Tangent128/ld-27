
local sprite = require "sprite"
local world = require "world"

local package, require = package, require

local SpriteSheet = sprite.SpriteSheet
local Sprite = world.Sprite

local _ENV = {}

-------------------------------------------------------------- SpriteSheets

GreenTiles = SpriteSheet("gl/tilesetStrip.png", 1, 20)

------------------------------------------------------------------ Bestiary?

Hero = require "Hero"

-- load from bestiary folder
local lpath = package.path
package.path = "bestiary/?.lua"

BeeSheet = SpriteSheet("bestiary/BeeSheet.png", 2, 2)
Bee = Sprite(0,0, 1, BeeSheet)

Sheep = require "Sheep"
Anvil = require "Anvil"
Bee = require "Bee"

package.path = lpath

return _ENV

