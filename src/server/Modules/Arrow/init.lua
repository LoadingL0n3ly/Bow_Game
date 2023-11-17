local class = {}

local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local Utils = ServerScriptService.Utils

local FastCast = require(Utils:WaitForChild("FastCastRedux"))


function class.OnLengthChanged(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
	-- Whenever the caster steps forward by one unit, this function is called.
	-- The bullet argument is the same object passed into the fire function.
	local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

function class.OnRayHit(cast, result: RaycastResult, segmentVelocity: Vector3, cosmeticBulletObject: Instance)
    
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