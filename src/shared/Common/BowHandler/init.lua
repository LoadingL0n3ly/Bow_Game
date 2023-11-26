local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = script.Parent
local Common = ReplicatedStorage:WaitForChild("Common")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BowRemotes = Remotes:WaitForChild("BowRemotes")
local EquipBowEvent: RemoteFunction = BowRemotes:WaitForChild("EquipBow")
local UnequipBowEvent: RemoteFunction = BowRemotes:WaitForChild("UnequipBow")
local FireEvent: RemoteEvent = BowRemotes:WaitForChild("Fire")

-- Modules
local Visual = require(script.Visual)
local Projectile = require(script.Projectile)
local Ammo = require(script.Ammo)

-- Fun Functions!
local function Equip(player: Player)
    print(`Recieved Equip Request from {player.Name}`)

    -- Setup
    local Character = player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end

    Visual.VisualEquip(player, "Test")
    Projectile.Equip(player)
    return true
end

local function Unequip(player: Player)
    print(`Recieved UnEquip Request from {player.Name}`)

    Projectile.Unequip(player)
    Visual.VisualUnequip(player)
    return true
end

function class.PlayerAdded(player: Player)
    Ammo.PlayerAdded(player)
end

function class.PlayerRemoving(player: Player)
    Ammo.PlayerRemoving(player)
end



function class.CharacterAdded(character: Model)
    local HitPart = Instance.new("Part")
    HitPart.Name = "HitPart"
    HitPart.Parent = character
    HitPart.Size = Vector3.new(6, 6, 3)
    HitPart.Transparency = 1
    HitPart.CanCollide = false
    HitPart.Position = character.HumanoidRootPart.Position

    if workspace:GetAttribute("Debug") then
        local Highlight: SelectionBox = Instance.new("SelectionBox")
        Highlight.Adornee = HitPart
        Highlight.Parent = HitPart
        Highlight.Color3 = Color3.fromRGB(255, 0, 0)
        Highlight.LineThickness = 0
    end

    local weld = Instance.new("Weld")
    weld.Parent = HitPart
    weld.Part0 = HitPart
    weld.Part1 = character.HumanoidRootPart
    weld.C0 = CFrame.new(0, 0, 0)
end

function class.Setup()
    EquipBowEvent.OnServerInvoke = Equip
    UnequipBowEvent.OnServerInvoke = Unequip
    FireEvent.OnServerEvent:Connect(Projectile.Fire)
    Ammo.Setup()
end


return class