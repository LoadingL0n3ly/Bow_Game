local class = {}

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Utils = ReplicatedStorage:WaitForChild("Utils")

local Arrow = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Arrow"))

local Gizmo = require(Utils.Gizmo)
Gizmo.Init()

local CastData = {}
-- Bow Remotes
local BowRemotes = Remotes:WaitForChild("BowRemotes")
local Replication: Folder = BowRemotes:WaitForChild("Replication")

local NewPlayerCasterEvent: RemoteEvent = Replication:WaitForChild("NewPlayerCaster")
local RemovePlayerCasterEvent: RemoteEvent = Replication:WaitForChild("RemovePlayerCaster")
local FireVisualProjectileEvent: RemoteEvent = Replication:WaitForChild("FireVisualProjectile")


local function NewPlayerCaster(player: Player, ModuleName: string)
    local ArrowModule = require(Arrow.ArrowModules[ModuleName])
    if not ArrowModule then warn("Arrow module isn't passed!") return end
    local Caster, FastCastBehavior = ArrowModule.New(player, player.Character, player.Character:FindFirstChild("Bow"))
    CastData[player] = {["Caster"] = Caster, ["FastCastBehavior"] = FastCastBehavior}
end

local function RemovePlayerCaster(player: Player)
    if not CastData[player] then return end
    CastData[player] = nil
end

local function FireVisualProjectile(player:Player, position: Vector3, direction: Vector3, force: number, CosmeticBullet: Instance, abilityToggle: boolean)
    if not CastData[player] then return end

    local Caster = CastData[player].Caster
    local Behavior = CastData[player].FastCastBehavior

    Behavior.CosmeticBulletTemplate = CosmeticBullet
    local cast = Caster:Fire(
        position,
        direction,
        force,
        Behavior
    )

    cast.UserData =  {Gen = {player = player, abilityToggle = abilityToggle}}
end

function class.Setup()
    -- connect events to corresponding functions
    NewPlayerCasterEvent.OnClientEvent:Connect(NewPlayerCaster)
    RemovePlayerCasterEvent.OnClientEvent:Connect(RemovePlayerCaster)
    FireVisualProjectileEvent.OnClientEvent:Connect(FireVisualProjectile)
end

return class