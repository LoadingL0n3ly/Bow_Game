local class = {}

class.ArrowModules = {
	["Test"] = script.TestArrow
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")


function class.OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	if not cosmeticBulletObject then return end
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function class.OnRayHit(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    if RunService:IsClient() then return end
	if result.Instance.Parent:FindFirstChild("Humanoid") then
		local humanoid = result.Instance.Parent:FindFirstChild("Humanoid")
		humanoid:TakeDamage(10)
	end
end

-- Pierce Functions
function class.RayPierced(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    
end

function class.CanRayPierce(cast, result: RaycastResult, segmentVelocity: Vector3)
    return false
end

function class.OnRayTerminated(cast)
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

return class