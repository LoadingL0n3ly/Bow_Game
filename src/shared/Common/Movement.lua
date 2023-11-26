local class = {}

-- Core Variables
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpsService = game:GetService("HttpService")

-- Debugging
local Debug = true

local Gizmo = require(script.Parent.Parent.Utils.Gizmo)
Gizmo.Init()

-- Constants
class.MovementStates = {
    Running = "Running",
    Sliding = "Sliding",
    Walking = "Walking",
    Crouching = "Crouching",
}

local SPRINT_SPEED = 30
local WALK_SPEED = 16
local CROUCH_SPEED = 5

local INSTANT_THRESHOLD = SPRINT_SPEED - WALK_SPEED
local ACCEL = 2 -- studs/second

-- Keybinds
local Sprint_Key = Enum.KeyCode.LeftShift
local Crouch_Key = Enum.KeyCode.C

-- State
local Character: Model
local Humanoid: Humanoid
local HRP: BasePart
local SlideForce: VectorForce
local State = class.MovementStates.Walking
local DesiredSpeed: number = WALK_SPEED
local SlideVelocity: Vector3
local SlideOrientation: AlignOrientation
local Attachment: Attachment
local Grounded = true

local SpeedTweens = {}
local HipTweens = {}

-- Core Functions
function class.CharacterAdded(character: Model)
    Character = character
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
end

function class.CharacterRemoved()
    Character, Humanoid, HRP, SlideForce = nil, nil, nil, nil
end

-- Controllers
local function ChangeDesiredSpeed(speed: number, smooth: boolean)
    DesiredSpeed = speed

    if math.abs(DesiredSpeed - Humanoid.WalkSpeed) <= INSTANT_THRESHOLD and not smooth then
        Humanoid.WalkSpeed = speed

    else
        local id = HttpsService:GenerateGUID(false)
        SpeedTweens[id] = TweenService:Create(Humanoid, TweenInfo.new(math.abs(DesiredSpeed - Humanoid.WalkSpeed * 0.05), Enum.EasingStyle.Back), {WalkSpeed = speed})
        SpeedTweens[id]:Play()
    end
end

-- Sprinting
local function StartSprint()
    State = class.MovementStates.Running
    ChangeDesiredSpeed(SPRINT_SPEED)

    for _, v in pairs(SpeedTweens) do
        v:Cancel()
    end
end

local function EndSprint()
    State = class.MovementStates.Walking
    ChangeDesiredSpeed(WALK_SPEED)
end

-- Sliding
local function StartSlide()
    SlideForce = Instance.new("BodyVelocity")
    SlideForce.Name = "SlideForce"
    SlideForce.Parent = HRP
    SlideForce.MaxForce = Vector3.new(math.huge, 0, math.huge)
    SlideForce.Velocity = Vector3.new(0, 0, 0)

    Attachment = Instance.new("Attachment")
    Attachment.Name = "SlideAttachment"
    Attachment.Parent = HRP

    SlideOrientation = Instance.new("AlignOrientation")
    SlideOrientation.Parent = Attachment
    SlideOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    SlideOrientation.Attachment0 = Attachment
    
    State = class.MovementStates.Sliding
    SlideVelocity = HRP.AssemblyLinearVelocity
    SlideForce.Velocity = Vector3.new(SlideVelocity.X, 0, SlideVelocity.Z) 
    Humanoid.HipHeight = -4

    local id = HttpsService:GenerateGUID(false)
    HipTweens[id] = TweenService:Create(Humanoid, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {HipHeight = -4})
    HipTweens[id]:Play()
    -- Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    Humanoid.AutoRotate = false
    HRP.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.5, 0, 0.5, 100)

    if not Grounded then
        HRP.AssemblyLinearVelocity -= Vector3.new(0, 5, 0)
    end
end

local function EndSlide()
    Humanoid.AutoRotate = true
    State = class.MovementStates.Walking
    local id = HttpsService:GenerateGUID(false)

    for _, v in pairs(HipTweens) do
        v:Cancel()
    end

    HipTweens[id] = TweenService:Create(Humanoid, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {HipHeight = 2})
    HipTweens[id]:Play()
    -- Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

    for _, v in pairs(HRP:GetChildren()) do
        if v.Name == "SlideForce" or v.Name == "SlideAttachment" then
            v:Destroy()
        end
    end
    SlideVelocity = nil
    ChangeDesiredSpeed(WALK_SPEED, true)
end

-- Connections
function class.Setup()
    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then return end
        
        if input.KeyCode == Sprint_Key then
            StartSprint()
        end

        if input.KeyCode == Crouch_Key then
            StartSlide()
        end
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then return end
        
        if input.KeyCode == Sprint_Key then
            EndSprint()
        end

        if input.KeyCode == Crouch_Key then
            EndSlide()
        end
    end)
end

local function ProjectOnPlane(v,n)    
    -- v is direction of movement, n is the surface normal of the wall
    return v - (((v:Dot(n))/(n.Magnitude)^2)*n)
end

function class.RenderStepped(dt)
    if not HRP then return end

    -- Raycast Stuff
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = {Character}
    local Raycast = workspace:Raycast(HRP.Position, Vector3.new(0, -4, 0), Params)

    if Raycast then
        Grounded = true
    else
        Grounded = false
    end

    -- Transformed Move Direction
    local MoveDir = Vector3.zero
    if Raycast then
        local Normal = Raycast.Normal
        local TransformedInput = ProjectOnPlane(Humanoid.MoveDirection, Normal)
        MoveDir = TransformedInput * dt * 2

        Gizmo.PushProperty("Color3", Color3.new(1, 0.360784, 0.913725))
        Gizmo.Arrow:Draw(HRP.Position, HRP.Position + MoveDir * 100, 0.1, 0.4, 9)
    end

    -- Gravitation
    local Gravity = Vector3.zero
    if Raycast then
        local Normal = Raycast.Normal
        local TransformedInput = ProjectOnPlane(Vector3.new(0, -1, 0), Normal) * 196.2
        Gravity = TransformedInput * dt

        Gizmo.PushProperty("Color3", Color3.new(0.435294, 1, 0.360784))
        Gizmo.Arrow:Draw(HRP.Position, HRP.Position + Gravity * 100, 0.1, 0.4, 9)
    end

    -- Apply
    if State ~= class.MovementStates.Sliding then return end

    -- Amount to subtract based off time due to friction
    local mult = 1
    if Raycast then
        local prop = Raycast.Instance.CustomPhysicalProperties or Raycast.Instance.CurrentPhysicalProperties
        mult = ((prop.Friction * (prop.FrictionWeight/100)) * 100)
    end

    local friction = -SlideForce.Velocity * math.min(dt, 1) * mult

    SlideForce.Velocity += MoveDir + Gravity + friction
    DesiredSpeed = SlideForce.Velocity.Magnitude
    Humanoid.WalkSpeed = DesiredSpeed

    if SlideForce.Velocity.Magnitude <= WALK_SPEED * 0.5 then
        EndSlide()
    end

    SlideOrientation.CFrame = CFrame.lookAt(Vector3.new(0,0,0), HRP.AssemblyLinearVelocity)
end
return class