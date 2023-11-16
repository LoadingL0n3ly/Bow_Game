local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Modules = script.Parent
local Common = ReplicatedStorage:WaitForChild("Common")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Ammo = require(script.Parent.Ammo)

local BowRemotes = Remotes:WaitForChild("BowRemotes")
local EquipBowEvent: RemoteFunction = BowRemotes:WaitForChild("EquipBow")
local UnequipBowEvent: RemoteFunction = BowRemotes:WaitForChild("UnequipBow")
local FireEvent: RemoteEvent = BowRemotes:WaitForChild("Fire")

local Utils = ServerScriptService:WaitForChild("Utils")
local FastCast = require(Utils:WaitForChild("FastCastRedux"))
local AssetHandler = require(script.Parent.AssetHandler)

local CastData = {}

-- VARIABLES THAT WILL BE UPDATED BY BOW STATS
local MaxForce = 30

-- Fire
function class.Fire(player: Player, direction: Vector3, force: number)
    local Character = player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    local FastCastData = CastData[player]
    if not FastCastData then return end

    local Result = Ammo.Fire(player)
    if not Result.CanFire then return warn(Result.Msg) end

    FastCastData.FastCastBehavior.CosmeticBulletTemplate = AssetHandler.GetArrow(player)
    FastCastData.Caster:Fire(
        Bow.Handle.Position,
        direction,
        math.clamp(force, 0, MaxForce) * 10,
        FastCastData.FastCastBehavior
    )
end


-- Setup Functions
function class.Equip(player: Player)
    local Character = player.Character

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then warn(`{player} has no Bow visually equipped`) return end

    -- Caster Setup
    

    CastData[player] = {["Caster"] = Caster, ["FastCastBehavior"] = FastCastBehavior}
end

function class.Unequip(player: Player)
    CastData[player] = nil
end

return class