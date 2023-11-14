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
        LastFire = os.time,
        AbilityArrowToggle = false,
    }
end

function class.PlayerRemoved(player: Player)
   if not Data[player] then return end 
   Data[player] = nil
end

-- Use
function class.Reset(player: Player)
    if not Data[player] then return end 

    local data = Data[player]
    data.AbilityArrows = ABILITY_ARROWS
    data.LastFire = os.time
end

function class.Fire(player: Player)
    local data = Data[player]
    if not data then return {CanFire = false, Msg = "No Data!"} end

    if os.time - data.LastFire < FIRE_COOLDOWN then return {CanFire = false, Msg = "Fire Cooldown Hit"} end
    if data.AbilityArrows <= 0 and data.AbilityArrowToggle then return {CanFire = false, Msg = "No Ability Arrows!"} end

    data.LastFire = os.time

    if data.AbilityArrowToggle then 
        data.AbilityArrows -= 1 
    end
end

function class.Tick()
    while task.wait(3) do
        for player, data in pairs(Data) do
            data.AbilityArrows += 1
        end
    end
end

return class