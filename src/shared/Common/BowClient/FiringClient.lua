local class = {}

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild("Common")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Utils = ReplicatedStorage:WaitForChild("Utils")

local Replication = require(script.Parent.Replication)
local Gizmo = require(Utils.Gizmo)
Gizmo.Init()

local Movement = require(Common.Movement)

-- Bow Remotes
local BowRemotes = Remotes:WaitForChild("BowRemotes")
local FireEvent: RemoteEvent = BowRemotes:WaitForChild("Fire")
local ToggleArrowEvent: RemoteFunction = BowRemotes:WaitForChild("ToggleArrow")
local UpdateAbilityArrowCountEvent: RemoteEvent = BowRemotes:WaitForChild("UpdateAbilityArrowCount")
-- Binds
local ToggleArrowBind = Enum.KeyCode.Q


-- UI STuff
local MouseConnection = {}
local Mouse = Player:GetMouse()

local PlayerGui = Player:WaitForChild("PlayerGui")
local Main = PlayerGui:WaitForChild("Main")
local ArrowType: TextLabel = Main:WaitForChild("ArrowType")
local AbilityArrowCount: TextLabel = Main:WaitForChild("AbilityArrowCount")
local Crosshair = Main:WaitForChild("Crosshair")

local OriginalCrosshairSize = Crosshair.Size

-- Constants
local ChargeUpMultiplier = 3 -- How much force is added every tenth of a second
local MaxForce = 30 -- The maximum force that can be applied to the arrow
local Interval = 0.05 -- How often the force is added to the arrow
local ResetFOV = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {FieldOfView = 70})
local ResetCrosshair = TweenService:Create(Crosshair, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {Size = OriginalCrosshairSize})


-- Vars
local ChargingUp = false
local Force = 0 
local FOVZoom: Tween = nil
local CrosshairZoom: Tween = nil

-- Functions
local function Charging()
    Force += ChargeUpMultiplier
    -- print(`Current Force: {Force}`)
    task.wait(Interval)
end

local function rayPlane(planepoint, planenormal, origin, direction)
	local p = -((origin-planepoint):Dot(planenormal))/(direction:Dot(planenormal))
    return origin + direction*p
end

local function GetAngle()
    local Camera = workspace.CurrentCamera
    local Character = Player.Character
    if not Character then return end

    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    local Bow = Character:FindFirstChild("Bow")
    if not Bow then return end

    local Ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local Hit = rayPlane(HRP.Position, HRP.CFrame.ZVector, Ray.Origin, Ray.Direction)
    local Direction = (Hit - Camera.CFrame.Position).Unit


    -- Now, find the point the player is aiming at
    local Params = RaycastParams.new()
    Params:AddToFilter(Character)
    Params:AddToFilter(Bow)

    local Result = workspace:Raycast(Camera.CFrame.Position, Direction * 3000, Params)
    if not Result then 
        -- Return the Direction pointing 1000 studs on the original direction
        local TargetPoint = Camera.CFrame.Position + (Direction * 1000)
        return (TargetPoint - Bow.Handle.Position).Unit
    end

    -- We have a point, so now we find the vector between the bow and the point
    local HitPoint = Result.Position
    Direction = (HitPoint - Bow.Handle.Position).Unit

    -- Then we have to confirm that the bow direction is not blocked by anything
    local NewResult = workspace:Raycast(Bow.Handle.Position, Direction * 3000, Params)
    if NewResult.Position ~= HitPoint then
        -- print("Bow is Blocked!")
    end

    Gizmo.PushProperty("Color3", Color3.new(1, 0.988235, 0.360784))
    Gizmo.Arrow:Draw(Bow.Handle.Position, HitPoint, 0.1, 0.4, 9)
    return Direction
end

-- RunService:BindToRenderStep("GetAngle", Enum.RenderPriority.Camera.Value - 1, GetAngle)

local function Fire(cancel: boolean)
    local Char = Player.Character
    if not Char then return end

    local HRP = Char:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    if not cancel then
        local Direction = GetAngle() or Vector3.new(0, 1, 0)
        FireEvent:FireServer(Direction, Force, HRP.Position)
    end
    
    ChargingUp = false
    if FOVZoom then FOVZoom:Cancel() end
    if CrosshairZoom then CrosshairZoom:Cancel() end

    ResetFOV:Play()
    ResetCrosshair:Play()

    FOVZoom = nil
    CrosshairZoom = nil

    Force = 0
end

local function Toggle()
    local result = ToggleArrowEvent:InvokeServer()

    if result then
        ArrowType.Text = "Ability Arrow"
        AbilityArrowCount.Visible = true
    else
        ArrowType.Text = "Normal Arrow"
        AbilityArrowCount.Visible = false
    end
end

local AbilityArrowCountVar = 3
local AbilityArrowToggleVar = false

local Cancelled = false
-- Setup Functions
function class.Equip()
   ArrowType.Visible = true
   
   MouseConnection["down"] = Mouse.Button1Down:Connect(function()
       local CanFire = (AbilityArrowToggleVar and AbilityArrowCountVar > 0) or (not AbilityArrowToggleVar)
       if not CanFire then
            Cancelled = true
            return
       end

       if Movement.State == Movement.MovementStates.Running then
            Movement.EndSprint()
       end

       Player.Character.Humanoid.AutoRotate = false
       
       ChargingUp = true

       local RemTime = (MaxForce/ChargeUpMultiplier) * Interval
       FOVZoom = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(RemTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {FieldOfView = 45})
       FOVZoom:Play()

       CrosshairZoom = TweenService:Create(Crosshair, TweenInfo.new(RemTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(OriginalCrosshairSize.X.Scale * 0.6, OriginalCrosshairSize.Y.Scale * 0.6)})
       CrosshairZoom:Play()

       while ChargingUp and Force < MaxForce do
           Charging()
       end
   end)

   MouseConnection["up"] = Mouse.Button1Up:Connect(function()
       if Cancelled then
            Cancelled = false
            return
       end
        Fire()

        Player.Character.Humanoid.AutoRotate = true
   end)

    MouseConnection["toggle"] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
         if gameProcessed then return end

         if input.KeyCode == ToggleArrowBind then
              Toggle()
              AbilityArrowToggleVar = not AbilityArrowToggleVar
         end
    end)

    MouseConnection["AbilityArrowCount"] = UpdateAbilityArrowCountEvent.OnClientEvent:Connect(function(count)
        AbilityArrowCount.Text = count
        AbilityArrowCountVar = count
    end)
end

function class.Unequip()
    AbilityArrowCount.Visible = false
    ArrowType.Visible = false
    Fire(true)
    
    for _, Connection in pairs(MouseConnection) do
        Connection:Disconnect()
    end
end



return class