local class = {}

local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local Utils = ServerScriptService.Utils

local Modules = ServerScriptService.Modules
local FastCast = require(Utils:WaitForChild("FastCastRedux"))
local Ammo = require(Modules.BowHandler:WaitForChild("Ammo"))
local StandardArrow = require(script.Parent)


local function OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
    if not cast.UserData.Gen.abilityToggle then
         StandardArrow.OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
         return
    end
    
    -- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function OnRayHit(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    if not cast.UserData.Gen.abilityToggle then
        StandardArrow.OnRayHit(cast, result, segmentVelocity, cosmeticBulletObject)
        return
    end

    if result.Instance.Parent:FindFirstChild("Humanoid") then
		local humanoid = result.Instance.Parent:FindFirstChild("Humanoid")
		
        if result.Instance.Parent:FindFirstChild("Head") then
            local head = result.Instance.Parent:FindFirstChild("Head")
            humanoid:TakeDamage(100)
            head.BrickColor = BrickColor.new("Really red")
        else
            humanoid:TakeDamage(25)
        end
	end
end

local function Reflect(surfaceNormal, bulletNormal)
	return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
end

-- Pierce Functions
local function RayPierced(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    if not cast.UserData.Gen.abilityToggle then
        StandardArrow.RayPierced(cast, result, segmentVelocity, cosmeticBulletObject)
        return
    end

    local position = result.Position
	local normal = result.Normal
	
	local newNormal = Reflect(normal, segmentVelocity.Unit)
	cast:SetVelocity(newNormal * segmentVelocity.Magnitude)
	
	-- It's super important that we set the cast's position to the ray hit position. Remember: When a pierce is successful, it increments the ray forward by one increment.
	-- If we don't do this, it'll actually start the bounce effect one segment *after* it continues through the object, which for thin walls, can cause the bullet to almost get stuck in the wall.
	cast:SetPosition(position)
end

local function CanRayPierce(cast, result: RaycastResult, segmentVelocity: Vector3)
    if not cast.UserData.Gen.abilityToggle then
        StandardArrow.CanRayPierce(cast, result, segmentVelocity)
        return false
    end

    return result.Instance:HasTag("Bounce")
end

local function OnRayTerminated(cast)
	if not cast.UserData.Gen.abilityToggle then
        StandardArrow.OnRayTerminated(cast)
        return
    end
    
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

-- constructor
function class.New(Player, Character, Bow)
    local Caster = FastCast.new()
    Caster.LengthChanged:Connect(OnLengthChanged)
    Caster.CastTerminating:Connect(OnRayTerminated)
    Caster.RayHit:Connect(OnRayHit)
    Caster.RayPierced:Connect(RayPierced)

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