local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local Rutils = ReplicatedStorage.Utils

local FastCast = require(Rutils:WaitForChild("FastCastRedux"))
FastCast.VisualizeCasts = false
local StandardArrow = require(script.Parent)

local RunService = game:GetService("RunService")

local function FindHumanoid(instance: Instance)
	local parent = instance
	while parent ~= nil and parent ~= workspace do
		if parent:FindFirstChild("Humanoid") then
			return parent:FindFirstChild("Humanoid")
		end
		parent = parent.Parent
	end
end

local function OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
    if not cast.UserData.Gen.abilityToggle then
         StandardArrow.OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
         return
    end
    
    --- Handles the server/client question since cosmetic bullet will only actually exist in the server
    if not cosmeticBulletObject then return end

	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

local function OnRayHit(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    if not cast.UserData.Gen.abilityToggle then
        StandardArrow.OnRayHit(cast, result, segmentVelocity, cosmeticBulletObject)
        return
    end

    if RunService:IsClient() then return end

    if FindHumanoid(result.Instance) then
		local humanoid = FindHumanoid(result.Instance)
		
        if result.Instance.Name == "Head" then
            local head = result.Instance
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

    if not cosmeticBulletObject then return end
    
    local emmitter: ParticleEmitter = cosmeticBulletObject:FindFirstChild("Attachment"):FindFirstChildWhichIsA("ParticleEmitter")
    -- if emmitter change the imagecolor to white for a seocnd
    local color = emmitter.Color
    if emmitter then
        emmitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
        task.delay(0.1, function()
            emmitter.Color = color
        end)
    end
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
    FastCastBehavior.RaycastParams:AddToFilter(workspace.Arrows:GetDescendants())
    FastCastBehavior.RaycastParams:AddToFilter(Bow:GetDescendants())
    FastCastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity * 0.1, 0)
    FastCastBehavior.CosmeticBulletContainer  = workspace.Arrows
    FastCastBehavior.CanPierceFunction = CanRayPierce

    return Caster, FastCastBehavior
end

return class