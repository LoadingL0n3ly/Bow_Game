local class = {}

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Utils = ReplicatedStorage:WaitForChild("Utils")

local Gizmo = require(Utils.Gizmo)
Gizmo.Init()

-- Bow Remotes
local BowRemotes = Remotes:WaitForChild("BowRemotes")
local FireEvent: RemoteEvent = BowRemotes:WaitForChild("Fire")

local MouseConnection = {}
local Mouse = Player:GetMouse()

-- Constants
local ChargeUpMultiplier = 3 -- How much force is added every tenth of a second
local MaxForce = 30 -- The maximum force that can be applied to the arrow
local Interval = 0.05 -- How often the force is added to the arrow
local ResetFOV = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {FieldOfView = 70})

-- Vars
local ChargingUp = false
local Force = 0 
local FOVZoom: TweenService = nil

-- Functions
local function Charging()
    Force += ChargeUpMultiplier
    print(`Current Force: {Force}`)
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

    Gizmo.PushProperty("Color3", Color3.new(1, 0.988235, 0.360784))
    Gizmo.Arrow:Draw(Bow.Handle.Position, (Direction * 10) + Hit, 0.1, 0.4, 9)

    return Direction
end

-- RunService:BindToRenderStep("GetAngle", Enum.RenderPriority.Camera.Value - 1, GetAngle)

local function Fire()
    print("Whoosh!")
    
    local Direction = GetAngle() or Vector3.new(0, 1, 0)
    FireEvent:FireServer(Direction, Force)
    
    ChargingUp = false
    FOVZoom:Cancel()
    ResetFOV:Play()
    FOVZoom = nil
    Force = 0
end

-- Setup Functions
function class.Equip()
   MouseConnection["down"] = Mouse.Button1Down:Connect(function()
       ChargingUp = true

       local RemTime = (MaxForce/ChargeUpMultiplier) * Interval
       FOVZoom = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(RemTime, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {FieldOfView = 30})
       FOVZoom:Play()

       while ChargingUp and Force < MaxForce do
           Charging()
       end
   end)

   MouseConnection["up"] = Mouse.Button1Up:Connect(function()
       Fire()
   end)
end

function class.Unequip()
    for _, Connection in pairs(MouseConnection) do
        Connection:Disconnect()
    end
end



return class