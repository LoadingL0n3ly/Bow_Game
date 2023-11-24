-- REMEMBER: THERE'S RESOURCES TO HELP YOU AT https://etithespirit.github.io/FastCastAPIDocs

-- Constants
local DEBUG = false								-- Whether or not to use debugging features of FastCast, such as cast visualization.
local BULLET_SPEED = 100							-- Studs/second - the speed of the bullet
local BULLET_MAXDIST = 1000							-- The furthest distance the bullet can travel 
local BULLET_GRAVITY = Vector3.new(0, -workspace.Gravity, 0)		-- The amount of gravity applied to the bullet in world space (so yes, you can have sideways gravity)
local MIN_BULLET_SPREAD_ANGLE = 1					-- THIS VALUE IS VERY SENSITIVE. Try to keep changes to it small. The least accurate the bullet can be. This angle value is in degrees. A value of 0 means straight forward. Generally you want to keep this at 0 so there's at least some chance of a 100% accurate shot.
local MAX_BULLET_SPREAD_ANGLE = 4					-- THIS VALUE IS VERY SENSITIVE. Try to keep changes to it small. The most accurate the bullet can be. This angle value is in degrees. A value of 0 means straight forward. This cannot be less than the value above. A value of 90 will allow the gun to shoot sideways at most, and a value of 180 will allow the gun to shoot backwards at most. Exceeding 180 will not add any more angular varience.
local FIRE_DELAY = 0								-- The amount of time that must pass after firing the gun before we can fire again.
local BULLETS_PER_SHOT = 1							-- The amount of bullets to fire every shot. Make this greater than 1 for a shotgun effect.
local PIERCE_DEMO = true							-- True if the pierce demo should be used. See the CanRayPierce function for more info.
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- Local Variables

local Tool = script.Parent
local Handle = Tool.Handle
local MouseEvent = Tool.MouseEvent
local FirePointObject = Handle.GunFirePoint
local FastCast = require(Tool.FastCastRedux)
local FireSound = Handle.Fire
local ImpactParticle = Handle.ImpactParticle
local Debris = game:GetService("Debris")
local table = require(Tool.FastCastRedux.Table)
local PartCacheModule = require(Tool.PartCache)
local CanFire = true								-- Used for a cooldown.

local RNG = Random.new()							-- Set up a randomizer.
local TAU = math.pi * 2							-- Set up mathematical constant Tau (pi * 2)
FastCast.DebugLogging = DEBUG
FastCast.VisualizeCasts = DEBUG

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- Cast Objects

-- Cosmetic bullet container
local CosmeticBulletsFolder = workspace:FindFirstChild("CosmeticBulletsFolder") or Instance.new("Folder", workspace)
CosmeticBulletsFolder.Name = "CosmeticBulletsFolder"

-- Now we set the caster values.
local Caster = FastCast.new() --Create a new caster object.

-- Make a base cosmetic bullet object. This will be cloned every time we fire off a ray.
local CosmeticBullet = Instance.new("Part")
CosmeticBullet.Material = Enum.Material.Neon
CosmeticBullet.Color = Color3.fromRGB(0, 196, 255)
CosmeticBullet.CanCollide = false
CosmeticBullet.Anchored = true
CosmeticBullet.Size = Vector3.new(0.2, 0.2, 2.4)

-- New raycast parameters.
local CastParams = RaycastParams.new()
CastParams.IgnoreWater = true
CastParams.FilterType = Enum.RaycastFilterType.Blacklist
CastParams.FilterDescendantsInstances = {}

-- NEW V13.1.0 - PartCache tie-in. If you use the PartCache module to create cosmetic bullets, you can now directly tie that in.
-- Ensure you're using the latest version of PartCache.
local CosmeticPartProvider = PartCacheModule.new(CosmeticBullet, 100, CosmeticBulletsFolder)

-- NEW v12.0.0: Casters now use a data packet which can be made like what follows.
-- Check the API for more information: https://etithespirit.github.io/FastCastAPIDocs/fastcast-objects/fcbehavior
local CastBehavior = FastCast.newBehavior()
CastBehavior.RaycastParams = CastParams
CastBehavior.MaxDistance = BULLET_MAXDIST
CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

-- CastBehavior.CosmeticBulletTemplate = CosmeticBullet -- Uncomment if you just want a simple template part and aren't using PartCache
CastBehavior.CosmeticBulletProvider = CosmeticPartProvider -- Comment out if you aren't using PartCache.

CastBehavior.CosmeticBulletContainer = CosmeticBulletsFolder
CastBehavior.Acceleration = BULLET_GRAVITY
CastBehavior.AutoIgnoreContainer = false -- We already do this! We don't need the default value of true (see the bottom of this script)

-- Bonus points: If you're going to be slinging a ton of bullets in a short period of time, you may see it fit to use PartCache.
-- https://devforum.roblox.com/t/partcache-for-all-your-quick-part-creation-needs/246641 

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- Helper Functions

-- A function to play fire sounds.
function PlayFireSound()
	local NewSound = FireSound:Clone()
	NewSound.Parent = Handle
	NewSound:Play()
	Debris:AddItem(NewSound, NewSound.TimeLength)
end

-- Create the spark effect for the bullet impact
function MakeParticleFX(position, normal)
	-- This is a trick I do with attachments all the time.
	-- Parent attachments to the Terrain - It counts as a part, and setting position/rotation/etc. of it will be in world space.
	-- UPD 11 JUNE 2019 - Attachments now have a "WorldPosition" value, but despite this, I still see it fit to parent attachments to terrain since its position never changes.
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position, position + normal)
	attachment.Parent = workspace.Terrain
	local particle = ImpactParticle:Clone()
	particle.Parent = attachment
	Debris:AddItem(attachment, particle.Lifetime.Max) -- Automatically delete the particle effect after its maximum lifetime.
	
	-- A potentially better option in favor of this would be to use the Emit method (Particle:Emit(numParticles)) though I prefer this since it adds some natural spacing between the particles.
	particle.Enabled = true
	wait(0.05)
	particle.Enabled = false
end

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- Main Logic

local function Reflect(surfaceNormal, bulletNormal)
	return bulletNormal - (2 * bulletNormal:Dot(surfaceNormal) * surfaceNormal)
end

-- The pierce function can also be used for things like bouncing.
-- In reality, it's more of a function that the module uses to ask "Do I end the cast now, or do I keep going?"
-- Because of this, you can use it for logic such as ray reflection or other redirection methods.
-- A great example might be to pierce or bounce based on something like velocity or angle.
-- You can see this implementation further down in the OnRayPierced function.
function CanRayPierce(cast, rayResult, segmentVelocity)
	
	-- Let's keep track of how many times we've hit something.
	local hits = cast.UserData.Hits
	if (hits == nil) then
		-- If the hit data isn't registered, set it to 1 (because this is our first hit)
		cast.UserData.Hits = 1
	else
		-- If the hit data is registered, add 1.
		cast.UserData.Hits += 1
	end
	
	-- And if the hit count is over 3, don't allow piercing and instead stop the ray.
	if (cast.UserData.Hits > 3) then
		return false
	end
	
	-- Now if we make it here, we want our ray to continue.
	-- This is extra important! If a bullet bounces off of something, maybe we want it to do damage too!
	-- So let's implement that.
	local hitPart = rayResult.Instance
	if hitPart ~= nil and hitPart.Parent ~= nil then
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(10) -- Damage.
		end
	end
	
	-- And then lastly, return true to tell FC to continue simulating.
	return true
	
	--[[
	-- This function shows off the piercing feature literally. Pass this function as the last argument (after bulletAcceleration) and it will run this every time the ray runs into an object.
	
	-- Do note that if you want this to work properly, you will need to edit the OnRayPierced event handler below so that it doesn't bounce.
	
	if material == Enum.Material.Plastic or material == Enum.Material.Ice or material == Enum.Material.Glass or material == Enum.Material.SmoothPlastic then
		-- Hit glass, plastic, or ice...
		if hitPart.Transparency >= 0.5 then
			-- And it's >= half transparent...
			return true -- Yes! We can pierce.
		end
	end
	return false
	--]]
end

function Fire(direction)
	-- Called when we want to fire the gun.
	if Tool.Parent:IsA("Backpack") then return end -- Can't fire if it's not equipped.
	-- Note: Above isn't in the event as it will prevent the CanFire value from being set as needed.
	
	-- UPD. 11 JUNE 2019 - Add support for random angles.
	local directionalCF = CFrame.new(Vector3.new(), direction)
	-- Now, we can use CFrame orientation to our advantage.
	-- Overwrite the existing Direction value.
	local direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(MIN_BULLET_SPREAD_ANGLE, MAX_BULLET_SPREAD_ANGLE)), 0, 0)).LookVector
	
	-- UPDATE V6: Proper bullet velocity!
	-- IF YOU DON'T WANT YOUR BULLETS MOVING WITH YOUR CHARACTER, REMOVE THE THREE LINES OF CODE BELOW THIS COMMENT.
	-- Requested by https://www.roblox.com/users/898618/profile/
	-- We need to make sure the bullet inherits the velocity of the gun as it fires, just like in real life.
	local humanoidRootPart = Tool.Parent:WaitForChild("HumanoidRootPart", 1)	-- Add a timeout to this.
	local myMovementSpeed = humanoidRootPart.Velocity							-- To do: It may be better to get this value on the clientside since the server will see this value differently due to ping and such.
	local modifiedBulletSpeed = (direction * BULLET_SPEED)-- + myMovementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.
	
	if PIERCE_DEMO then
		CastBehavior.CanPierceFunction = CanRayPierce
	end
	
	local simBullet = Caster:Fire(FirePointObject.WorldPosition, direction, modifiedBulletSpeed, CastBehavior)
	-- Optionally use some methods on simBullet here if applicable.
	
	-- Play the sound
	PlayFireSound()
end

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
-- Event Handlers

function OnRayHit(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- This function will be connected to the Caster's "RayHit" event.
	local hitPart = raycastResult.Instance
	local hitPoint = raycastResult.Position
	local normal = raycastResult.Normal
	if hitPart ~= nil and hitPart.Parent ~= nil then -- Test if we hit something
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid") -- Is there a humanoid?
		if humanoid then
			humanoid:TakeDamage(10) -- Damage.
		end
		MakeParticleFX(hitPoint, normal) -- Particle FX
	end
end

function OnRayPierced(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
	-- You can do some really unique stuff with pierce behavior - In reality, pierce is just the module's way of asking "Do I keep the bullet going, or do I stop it here?"
	-- You can make use of this unique behavior in a manner like this, for instance, which causes bullets to be bouncy.
	local position = raycastResult.Position
	local normal = raycastResult.Normal
	
	local newNormal = Reflect(normal, segmentVelocity.Unit)
	cast:SetVelocity(newNormal * segmentVelocity.Magnitude)
	
	-- It's super important that we set the cast's position to the ray hit position. Remember: When a pierce is successful, it increments the ray forward by one increment.
	-- If we don't do this, it'll actually start the bounce effect one segment *after* it continues through the object, which for thin walls, can cause the bullet to almost get stuck in the wall.
	cast:SetPosition(position)
	
	-- Generally speaking, if you plan to do any velocity modifications to the bullet at all, you should use the line above to reset the position to where it was when the pierce was registered.
end

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
		-- This code here is using an if statement on CastBehavior.CosmeticBulletProvider so that the example gun works out of the box.
		-- In your implementation, you should only handle what you're doing (if you use a PartCache, ALWAYS use ReturnPart. If not, ALWAYS use Destroy.
		if CastBehavior.CosmeticBulletProvider ~= nil then
			CastBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
		else
			cosmeticBullet:Destroy()
		end
	end
end

MouseEvent.OnServerEvent:Connect(function (clientThatFired, mousePoint)
	if not CanFire then
		return
	end
	CanFire = false
	local mouseDirection = (mousePoint - FirePointObject.WorldPosition).Unit
	for i = 1, BULLETS_PER_SHOT do
		Fire(mouseDirection)
	end
	if FIRE_DELAY > 0.03 then wait(FIRE_DELAY) end
	CanFire = true
end)

Caster.RayHit:Connect(OnRayHit)
Caster.RayPierced:Connect(OnRayPierced)
Caster.LengthChanged:Connect(OnRayUpdated)
Caster.CastTerminating:Connect(OnRayTerminated)

Tool.Equipped:Connect(function ()
	CastParams.FilterDescendantsInstances = {Tool.Parent, CosmeticBulletsFolder}
end)


------------------------------------------------------------------------------------------------------------------------------
-- In production scripts that you are writing that you know you will write properly, you should not do this.
-- This is included exclusively as a result of this being an example script, and users may tweak the values incorrectly.
assert(MAX_BULLET_SPREAD_ANGLE >= MIN_BULLET_SPREAD_ANGLE, "Error: MAX_BULLET_SPREAD_ANGLE cannot be less than MIN_BULLET_SPREAD_ANGLE!")
if (MAX_BULLET_SPREAD_ANGLE > 180) then
	warn("Warning: MAX_BULLET_SPREAD_ANGLE is over 180! This will not pose any extra angular randomization. The value has been changed to 180 as a result of this.")
	MAX_BULLET_SPREAD_ANGLE = 180
end