local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild("Common")
local RunService = game:GetService("RunService")

-- Modules
local BowClient = require(Common:WaitForChild("BowClient"))
-- local DoubleJump = require(Common:WaitForChild("DoubleJump"))
local Movement = require(Common:WaitForChild("Movement"))
local ChatClient = require(Common:WaitForChild("ChatClient"))

local function CharacterAdded(char: Model)
    Movement.CharacterAdded(char)
end

local function CharacterRemoved()
    Movement.CharacterRemoved()
end

if Player.Character then
    CharacterAdded(Player.Character)
end

Player.CharacterAdded:Connect(CharacterAdded)
Player.CharacterRemoving:Connect(CharacterRemoved)

-- Setup
Movement.Setup()
BowClient.Setup()
-- DoubleJump.Setup()

-- Connectiuons
local BowPullAnimation: Animation = Instance.new("Animation")
BowPullAnimation.AnimationId = "rbxassetid://15518187062"


local function Added(descendant: Instance)
    if descendant:HasTag("StringPull") and descendant.Parent.Name == "Handle" then
        local Handle: Part = descendant.Parent
        local Bow: Model = Handle.Parent
        local StringPull: Attachment = descendant

        local AnimationController: AnimationController = Bow:FindFirstChildOfClass("AnimationController")
        if not AnimationController then warn("no animation controller") return end

        local Animator: Animator = AnimationController:FindFirstChildOfClass("Animator")
        if not Animator then warn("no aniamtor") return end

        local AnimationTrack: AnimationTrack = Animator:LoadAnimation(BowPullAnimation)
        AnimationTrack:Play(0.100000001, 1, 0)

        -- this is a pretty scrappy implementation, I'll so totally clean it up later and defenitely not let it into production
        local Dist = -1.1139948921203613

        local function UpdateAnimation()
            local pullCFrame = StringPull.CFrame
            --StringPull.CFrame = CFrame.new(Vector3.new(pullCFrame.Position.X, pullCFrame.Position.Y, math.clamp(pullCFrame.Position.Z, -2.2, Dist)))

            local Z = pullCFrame.Position.Z + 1.116

            local timePos = math.clamp((Z/Dist), 0, 1) * AnimationTrack.Length
            --print(math.clamp((Z/Dist), 0, 1), pullCFrame.Position.Z)
            AnimationTrack.TimePosition = timePos
        end

        StringPull:GetPropertyChangedSignal("CFrame"):Connect(UpdateAnimation)
    end
end

for _, descendant in pairs(workspace:GetDescendants()) do
    Added(descendant)
end

workspace.DescendantAdded:Connect(function(descendant)
    Added(descendant)
end)


RunService.RenderStepped:Connect(function(dt: number)
    Movement.RenderStepped(dt)
end)
