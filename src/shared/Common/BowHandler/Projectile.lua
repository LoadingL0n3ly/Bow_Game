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

-- Replication Remotes
local Replication: Folder = BowRemotes:WaitForChild("Replication")

local NewPlayerCasterEvent: RemoteEvent = Replication:WaitForChild("NewPlayerCaster")
local RemovePlayerCasterEvent: RemoteEvent = Replication:WaitForChild("RemovePlayerCaster")
local FireVisualProjectileEvent: RemoteEvent = Replication:WaitForChild("FireVisualProjectile")

local Rutils = ReplicatedStorage:WaitForChild("Utils")
local FastCast = require(Rutils:WaitForChild("FastCastRedux"))
local AssetHandler = require(script.Parent.AssetHandler)
local DataManager = require(script.Parent.DataManager)

local CastData = {}

-- VARIABLES THAT WILL BE UPDATED BY BOW STATS
local MaxForce = 30

-- Fire
function class.Fire(player: Player, direction: Vector3, force: number, playerPos: Vector3)
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
    --AssetHandler.GetArrow(player)
    local cast = FastCastData.Caster:Fire(
        Bow.Handle.Position,
        direction,
        math.clamp(force, 0, MaxForce) * 25,
        FastCastData.FastCastBehavior
    )
    cast.UserData = {Gen = {player = player, abilityToggle = Ammo.GetAbilityArrowToggle(player)}}

    FireVisualProjectileEvent:FireAllClients(player, Bow.Handle.Position, direction, math.clamp(force, 0, MaxForce) * 25, AssetHandler.GetArrow(player), Ammo.GetAbilityArrowToggle(player))
end


-- Setup Functions
function class.Equip(player: Player)
    local Character = player.Character

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then warn(`{player} has no Bow visually equipped`) return end

    -- Caster Setup
    
    local Module, bowName = DataManager.GetArrowModule(player)
    local Caster, FastCastBehavior = Module.New(player, Character, Bow)
    CastData[player] = {["Caster"] = Caster, ["FastCastBehavior"] = FastCastBehavior}

    NewPlayerCasterEvent:FireAllClients(player, bowName)
end

function class.Unequip(player: Player)
    CastData[player] = nil
    RemovePlayerCasterEvent:FireAllClients(player)
end

return class