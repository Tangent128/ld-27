
local sprite = require "sprite"
local world = require "world"

local package, require = package, require

local SpriteSheet = sprite.SpriteSheet
local Sprite = world.Sprite

local _ENV = {}

-------------------------------------------------------------- SpriteSheets

GreenTiles = SpriteSheet("gl/tilesetStrip.png", 1, 20)
ClockTiles = SpriteSheet("gl/clockDigits.png", 3, 11)

PauseScreen = SpriteSheet("gl/Pause.png", 1, 1)

StartScreen = SpriteSheet("gl/WIPTitle4.png", 1, 1)

GameOver = SpriteSheet("gl/WIPGameOver3.png", 1, 1)

------------------------------------------------------------------ Bestiary?

Hero = require "Hero"
Puffball = require "Puffball"
Projectile = require "Projectile"

-- load from bestiary folder
local lpath = package.path
package.path = "bestiary/?.lua;lua/?.lua"

Sheep = require "Sheep"
Anvil = require "Anvil"
Bee = require "Bee"
Projectile = require "Projectile"
Clock = require "Clock"
Conehead = require "Conehead"

package.path = lpath

return _ENV

