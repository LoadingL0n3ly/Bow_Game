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

function class.Setup()
    EquipBowEvent.OnServerInvoke = Equip
    UnequipBowEvent.OnServerInvoke = Unequip
    FireEvent.OnServerEvent:Connect(Projectile.Fire)
end


return class