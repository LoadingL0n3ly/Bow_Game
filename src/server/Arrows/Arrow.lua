local class = {}

local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local Utils = ServerScriptService.Utils

local FastCast = require(Utils:WaitForChild("FastCastRedux"))


local function OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function OnRayHit(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    
end

-- Pierce Functions
local function RayPierced(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    
end

local function CanRayPierce(cast, result: RaycastResult, segmentVelocity: Vector3)
    return false
end

local function OnRayTerminated(cast)
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		task.delay(3, function()
            local TransparencyTween = TweenService:Create(cosmeticBullet, TweenInfo.new(3, Enum.EasingStyle.Linear), {Transparency = 1})
            TransparencyTween:Play()s
            
            TransparencyTween.Completed:Once(function()
                cosmeticBullet:Destroy()
            end)
        end)
	end
end

-- constructor
function class.NewCast(Player, Character, Bow)
    local Caster = FastCast.new()
    Caster.LengthChanged:Connect(OnLengthChanged)
    Caster.CastTerminating:Connect(OnRayTerminated)
    Caster.RayHit:Connect(OnRayHit)
    Caster.RayPierced:Connect(RayPierced)
    Caster.UserData = {player = Player, character = Character, bow = Bow}

    local FastCastBehavior = FastCast.newBehavior()
    FastCastBehavior.RaycastParams = RaycastParams.new()
    FastCastBehavior.RaycastParams:AddToFilter(Character:GetDescendants())
    FastCastBehavior.RaycastParams:AddToFilter(Bow:GetDescendants())
    FastCastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity * 0.1, 0)
    FastCastBehavior.CosmeticBulletContainer  = workspace.Arrows
    FastCastBehavior.CanPierceFunction = CanRayPierce

    return Caster, FastCastBehavior
end

return class