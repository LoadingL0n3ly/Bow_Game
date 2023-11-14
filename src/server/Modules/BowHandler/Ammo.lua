local class = {}

local Players = game.Players

-- Ammo Data
local Data = {}

-- Constants
local FIRE_COOLDOWN = 0.5
local ABILITY_ARROWS = 3
local ARROW_REGEN = 3

-- Config
function class.PlayerAdded(player: Player)
    Data[player] = {
        AbilityArrows = ABILITY_ARROWS,
        LastFire = tick(),
    }
end

function class.PlayerRemoved(player: Player)
   if not Data[player] then return end 
   Data[player] = nil
end

-- Use
function class.Reset(player: Player)
    if not Data[player] then return end 

    Data[player] = {
        AbilityArrows = ABILITY_ARROWS,
        LastFire = tick(),
    }
end

return class