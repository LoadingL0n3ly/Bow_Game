local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Bows = Assets.Bows
local AmmmoHandler = require(script.Parent.Ammo)

local Arrows = Assets.Arrows

function class.GetBow(player: Player)
    -- code to get the kind of bow player has
    local bowName = "Test"
    local _bow = Bows:WaitForChild(bowName)

    return _bow:Clone()
end

function class.GetArrow(player: Player)
    -- code to get the kind of bow player has
    local bowName = "Test"

    local AbilityArrowToggle = AmmmoHandler.GetAbilityARrowToggle(player)
    local arrowFolder = Arrows:FindFirstChild(bowName)

    if AbilityArrowToggle then
        return arrowFolder:FindFirstChild("Ability")
    else
        return arrowFolder:FindFirstChild("Normal")
    end
end

return class