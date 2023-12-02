local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage.Assets
local Bows = Assets.Bows
local AssetHandler = require(script.Parent.AssetHandler)

function class.VisualEquip(player: Player, bowName: string)
    local BowModel = AssetHandler.GetBow(player)

    local Character = player.Character
    local Humanoid = Character.Humanoid

    local RootPart: Part = BowModel:FindFirstChild("Handle")
    local Grip: Attachment = RootPart:FindFirstChild("Grip")

    -- Weld Grip to RightHand
    local RightHand = Character:FindFirstChild("RightHand")
    if not RightHand then return end

    local RightGripAttachment = RightHand:FindFirstChild("RightGripAttachment")
    if not RightGripAttachment then return end

    local Weld = Instance.new("Weld")
    Weld.Name = "Weld"
    Weld.Part0 = RightHand
    Weld.Part1 = RootPart
    Weld.C0 = RightGripAttachment.CFrame:Inverse() * Grip.CFrame
    Weld.Parent = RightHand

    BowModel.Parent = Character
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