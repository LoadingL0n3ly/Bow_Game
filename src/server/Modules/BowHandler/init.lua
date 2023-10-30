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

local Utils = ServerScriptService:WaitForChild("Utils")
local FastCast = require(Utils:WaitForChild("FastCastRedux"))

local CastData = {}

-- VARIABLES THAT WILL BE UPDATED BY BOW STATS
local MaxForce = 30

local CosmeticBullet = Instance.new("Part")
CosmeticBullet.Material = Enum.Material.Neon
CosmeticBullet.Color = Color3.fromRGB(0, 196, 255)
CosmeticBullet.CanCollide = false
CosmeticBullet.Anchored = true
CosmeticBullet.Size = Vector3.new(0.2, 0.2, 2.4)

-- Projectile 
local function Fire(player: Player, direction: Vector3, force: number)
    print(`Recieved Fire Request from {player.Name}`)

    local Character = player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    local FastCastData = CastData[player]
    if not FastCastData then return end

    print("Bombs away!")
    FastCastData.Caster:Fire(
        Bow.Handle.Position,
        direction,
        math.clamp(force, 0, MaxForce) * 10,
        FastCastData.FastCastBehavior
    )
end

-- Modules
local Visual = require(script.Visual)

-- Caster Functions
function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	if cosmeticBulletObject == nil then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function Equip(player: Player)
    print(`Recieved Equip Request from {player.Name}`)

    -- Setup
    local Character = player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end
    Visual.VisualEquip(player, "Test")

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    local Projectile = Bow:FindFirstChild("Arrow") -- probably switch to custom arrow?
    if not Projectile then return end

    -- Caster Setup
    local Caster = FastCast.new()
    Caster.LengthChanged:Connect(OnRayUpdated)

    -- FastCast.VisualizeCasts = true
    FastCast.DebugLogging = true

    local FastCastBehavior = FastCast.newBehavior()
    FastCastBehavior.RaycastParams = RaycastParams.new()
    FastCastBehavior.RaycastParams:AddToFilter(Character:GetDescendants())
    FastCastBehavior.RaycastParams:AddToFilter(Bow:GetDescendants())

    FastCastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity * 0.1, 0)
    FastCastBehavior.CosmeticBulletTemplate = Projectile
    FastCastBehavior.CosmeticBulletContainer  = workspace.Arrows

    CastData[player] = {["Caster"] = Caster, ["FastCastBehavior"] = FastCastBehavior}
    return true
end

local function Unequip(player: Player)
    print(`Recieved UnEquip Request from {player.Name}`)

    CastData[player] = nil
    Visual.VisualUnequip(player)
    return true
end

function class.Setup()
    EquipBowEvent.OnServerInvoke = Equip
    UnequipBowEvent.OnServerInvoke = Unequip
    FireEvent.OnServerEvent:Connect(Fire)
end


return class