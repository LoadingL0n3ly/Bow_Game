local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Modules = script.Parent
local Common = ReplicatedStorage:WaitForChild("Common")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

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

-- Fastcast Behavior Functions

-- TODO: Update all of these to use the Bow Behavior Modules!
function OnRayUpdated(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	if cosmeticBulletObject == nil then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function OnRayTerminated(cast)
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		task.delay(3, function()
            local TransparencyTween = TweenService:Create(cosmeticBullet, TweenInfo.new(3, Enum.EasingStyle.Linear), {Transparency = 1})
            TransparencyTween:Play()

            TransparencyTween.Completed:Once(function()
                cosmeticBullet:Destroy()
            end)
        end)
	end
end

-- Fire
function class.Fire(player: Player, direction: Vector3, force: number)
    print(`Recieved Fire Request from {player.Name}`)

    local Character = player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid then return end

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    local FastCastData = CastData[player]
    if not FastCastData then return end

    FastCastData.FastCastBehavior.CosmeticBulletTemplate = AssetHandler.GetArrow(player)
    print(FastCastData.FastCastBehavior.CosmeticBulletTemplate.Name)

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

    -- local Projectile = AssetHandler.GetArrow(player)
    -- if not Projectile then warn(`{player} has no Arrow visually equipped`) return end

    -- Caster Setup
    local Caster = FastCast.new()
    Caster.LengthChanged:Connect(OnRayUpdated)
    Caster.CastTerminating:Connect(OnRayTerminated)

    -- FastCast.VisualizeCasts = true
    -- FastCast.DebugLogging = true

    local FastCastBehavior = FastCast.newBehavior()
    FastCastBehavior.RaycastParams = RaycastParams.new()
    FastCastBehavior.RaycastParams:AddToFilter(Character:GetDescendants())
    FastCastBehavior.RaycastParams:AddToFilter(Bow:GetDescendants())

    FastCastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity * 0.1, 0)
    -- FastCastBehavior.CosmeticBulletTemplate = Projectile
    FastCastBehavior.CosmeticBulletContainer  = workspace.Arrows

    CastData[player] = {["Caster"] = Caster, ["FastCastBehavior"] = FastCastBehavior}
end

function class.Unequip(player: Player)
    CastData[player] = nil
end

return class