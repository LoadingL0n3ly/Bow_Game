local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Bows = Assets.Bows
local AssetHandler = require(script.Parent.AssetHandler)

function class.VisualEquip(player: Player, bowName: string)
    local BowModel = AssetHandler.GetBow(player)

    local Character = player.Character
    local Humanoid = Character.Humanoid

    Humanoid:AddAccessory(BowModel)
    BowModel.Name = "Bow"
end

function class.VisualUnequip(player: Player)
    local Character = player.Character
    if not Character then return end

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    Bow:Destroy()
end

return class