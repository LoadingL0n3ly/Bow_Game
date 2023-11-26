local class = {}

-- Core Variables
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpsService = game:GetService("HttpService")

local Gizmo = require(script.Parent.Parent.Utils.Gizmo)
Gizmo.Init()

-- Constants
class.MovementStates = {
    Running = "Running",
    Sliding = "Sliding",
    Walking = "Walking",
    Crouching = "Crouching",
}

local SPRINT_SPEED = 40
local WALK_SPEED = 16
local JUMP_BOOST = 100

local INSTANT_THRESHOLD = SPRINT_SPEED - WALK_SPEED
local ACCEL = 2 -- studs/second
local DOUBLE_JUMP_COOLDOWN = 0.1 -- seconds

-- Keybinds
local Sprint_Key = Enum.KeyCode.LeftShift
local Crouch_Key = Enum.KeyCode.C
local Double_Jump_Key = Enum.KeyCode.Space

-- Animations
local SlideAnimation = Instance.new("Animation")
SlideAnimation.AnimationId = "rbxassetid://15474655816"

local DoubleJumpAnimation = Instance.new("Animation")
DoubleJumpAnimation.AnimationId = "rbxassetid://15474638467"

local RunAnimation = Instance.new("Animation")
RunAnimation.AnimationId = "rbxassetid://15474653075"

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
local SlideAnimationTrack: AnimationTrack
local RunAnimationTrack: AnimationTrack
local DoubleJumpAnimationTrack: AnimationTrack
local animator: Animator
local lastJump: number

local SpeedTweens = {}

-- Core Functions
function class.CharacterAdded(character: Model)
    Character = character
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
    animator = Humanoid:FindFirstChildOfClass("Animator")
    lastJump = os.time()
end

function class.CharacterRemoved()
    Character, Humanoid, HRP, SlideForce, SlideAnimationTrack, RunAnimationTrack, lastJump = nil, nil, nil, nil, nil, nil, nil
end

-- Controllers
function class.ChangeDesiredSpeed(speed: number, smooth: boolean)
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
function class.StartSprint()
    if State == class.MovementStates.Sliding then return end
    if State == class.MovementStates.Sliding then
        class.EndSlide()
    end

    if RunAnimationTrack then
        RunAnimationTrack:Play()
    else
        RunAnimationTrack = animator:LoadAnimation(RunAnimation)
        RunAnimationTrack:Play()
    end

    State = class.MovementStates.Running
    class.ChangeDesiredSpeed(SPRINT_SPEED)

    for _, v in pairs(SpeedTweens) do
        v:Cancel()
    end
end

function class.EndSprint()
    State = class.MovementStates.Walking
    class.ChangeDesiredSpeed(WALK_SPEED)

    if RunAnimationTrack then
        RunAnimationTrack:Stop()
    end
end

-- Sliding
function class.StartSlide()
    if State == class.MovementStates.Sliding then return end
    if State == class.MovementStates.Running then class.EndSprint() end

    if SlideAnimationTrack then
        SlideAnimationTrack:Play()
    else
        SlideAnimationTrack = animator:LoadAnimation(SlideAnimation)
        SlideAnimationTrack:Play()
    end

    SlideForce = Instance.new("BodyVelocity")
    SlideForce.Name = "SlideForce"
    SlideForce.Parent = HRP
    SlideForce.MaxForce = Vector3.new(math.huge, 0, math.huge)
    SlideForce.Velocity = Vector3.new(0, 0, 0)

    Attachment = ReplicatedStorage.AttachmentStorage.SlideAttachment:Clone()
    Attachment.Parent = HRP

    SlideOrientation = Instance.new("AlignOrientation")
    SlideOrientation.Parent = Attachment
    SlideOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    SlideOrientation.Attachment0 = Attachment
    SlideOrientation.RigidityEnabled = true
    
    State = class.MovementStates.Sliding
    SlideVelocity = HRP.AssemblyLinearVelocity
    
    local YMod: number = math.clamp(math.abs(SlideVelocity.Y) * 0.05, 1, 3) 

    -- TODO: Implement Ymod Later when Code is more Stable
    SlideForce.Velocity = Vector3.new(SlideVelocity.X, 0, SlideVelocity.Z)  --* YMod

    Humanoid.AutoRotate = false
    HRP.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.5, 0, 0.5, 100)

    if not Grounded then
        HRP.AssemblyLinearVelocity -= Vector3.new(0, 5, 0)
    end
end

function class.EndSlide()
    Humanoid.AutoRotate = true
    State = class.MovementStates.Walking

    for _, v in pairs(HRP:GetChildren()) do
        if v.Name == "SlideForce" or v.Name == "SlideAttachment" then
            v:Destroy()
        end
    end
    SlideVelocity = nil

    if SlideAnimationTrack then
        SlideAnimationTrack:Stop()
    end

    class.ChangeDesiredSpeed(WALK_SPEED, true)
end

-- Double Jumping
function class.AttemptJump()
    local state = Humanoid:GetState()
    if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FallingDown then
        if os.time() - lastJump >= DOUBLE_JUMP_COOLDOWN then
            if State == class.MovementStates.Sliding then
                class.EndSlide()
            end

            if State == class.MovementStates.Running then
                class.EndSprint()
            end
            
            if DoubleJumpAnimationTrack then
                DoubleJumpAnimationTrack:Play()
            else
                DoubleJumpAnimationTrack = animator:LoadAnimation(DoubleJumpAnimation)
                DoubleJumpAnimationTrack:Play()
            end
            
            HRP.AssemblyLinearVelocity += Vector3.new(0, JUMP_BOOST, 0)
            lastJump = os.time()            
        end
    end
end

-- Connections
function class.Setup()
    UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then return end
        
        if input.KeyCode == Sprint_Key then
            class.StartSprint()
        end

        if input.KeyCode == Crouch_Key then
            class.StartSlide()
        end

        if input.KeyCode == Double_Jump_Key then
            class.AttemptJump()
        end
    end)

    UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed then return end
        
        if input.KeyCode == Sprint_Key then
            class.EndSprint()
        end

        if input.KeyCode == Crouch_Key then
            class.EndSlide()
        end
    end)
end

local function ProjectOnPlane(v,n)    
    -- v is direction of movement, n is the surface normal of the wall
    return v - (((v:Dot(n))/(n.Magnitude)^2)*n)
end

function class.RenderStepped(dt)
    if not HRP then return end
    local Debug = workspace:GetAttribute("Debug")

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

    if Grounded and DoubleJumpAnimationTrack then
        DoubleJumpAnimationTrack:Stop()
    end

    -- Transformed Move Direction
    local MoveDir = Vector3.zero
    if Raycast then
        local Normal = Raycast.Normal
        local TransformedInput = ProjectOnPlane(Humanoid.MoveDirection, Normal)
        MoveDir = TransformedInput * dt * 2

        if Debug then
            Gizmo.PushProperty("Color3", Color3.new(1, 0.360784, 0.913725))
            Gizmo.Arrow:Draw(HRP.Position, HRP.Position + MoveDir * 100, 0.1, 0.4, 9)
        end
    end

    -- Gravitation
    local Gravity = Vector3.zero
    if Raycast then
        local Normal = Raycast.Normal
        local TransformedInput = ProjectOnPlane(Vector3.new(0, -1, 0), Normal) * 196.2
        Gravity = TransformedInput * dt

        if Debug then
            Gizmo.PushProperty("Color3", Color3.new(0.435294, 1, 0.360784))
            Gizmo.Arrow:Draw(HRP.Position, HRP.Position + Gravity * 100, 0.1, 0.4, 9)
        end
    end

    -- Apply
    if State ~= class.MovementStates.Sliding then return end

    -- Amount to subtract based off time due to friction
    local mult = 1
    if Raycast then
        local prop = Raycast.Instance.CustomPhysicalProperties or Raycast.Instance.CurrentPhysicalProperties
        mult = ((prop.Friction * (prop.FrictionWeight/100)) * 100)
    end

    -- alligment stuff
    if Raycast then
        local look = HRP.AssemblyLinearVelocity
		local normal = Raycast.Normal
		
		local proj_look_onto_normal = look:Dot(normal) * normal
		local proj_look_onto_ground_plane = look - proj_look_onto_normal
		if Debug then
            Gizmo.PushProperty("Color3", Color3.new(0.796078, 0.627451, 1))
		    Gizmo.Arrow:Draw(HRP.Position, HRP.Position + look, 0.05, 0.1, 9)
        end
		
		local computed_right = proj_look_onto_ground_plane.Unit:Cross(normal)
		if Debug then
            Gizmo.PushProperty("Color3", Color3.new(1, 0.184313, 0.184313))
		    Gizmo.Arrow:Draw(HRP.Position, HRP.Position + computed_right, 0.05, 0.1, 9)
        end
		
		-- the 'computed up vector' is the normal
		if Debug then
            Gizmo.PushProperty("Color3", Color3.new(0.184313, 1, 0.184313))
		    Gizmo.Arrow:Draw(HRP.Position, HRP.Position + normal, 0.05, 0.1, 9)
        end
		
		-- use the computed vectors
		-- rotate to match primary axis upward
        if normal:Dot(Vector3.new(0,1,0)) < 0.5 then
            normal = Vector3.new(0,1,0)
        end

		local CalculatedFrame = CFrame.fromMatrix(HRP.Position, computed_right, normal, -(proj_look_onto_ground_plane.Unit)) * CFrame.Angles(0, 0, math.pi/2)
		SlideOrientation.CFrame = CalculatedFrame
        SlideOrientation.Enabled = true
    end


    local friction = -SlideForce.Velocity * math.min(dt, 1) * mult

    SlideForce.Velocity += MoveDir + Gravity + friction
    
    if SlideForce.Velocity.Magnitude >= WALK_SPEED then
        DesiredSpeed = SlideForce.Velocity.Magnitude
        Humanoid.WalkSpeed = DesiredSpeed
    end

    if SlideForce.Velocity.Magnitude <= WALK_SPEED * 0.5 then
        class.EndSlide()
    end
end
return class