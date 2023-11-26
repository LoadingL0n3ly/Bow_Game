local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild("Common")
local RunService = game:GetService("RunService")

-- Modules
local BowClient = require(Common:WaitForChild("BowClient"))
local DoubleJump = require(Common:WaitForChild("DoubleJump"))
local Movement = require(Common:WaitForChild("Movement"))


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
DoubleJump.Setup()

-- Connectiuons
RunService.RenderStepped:Connect(function(dt: number)
    Movement.RenderStepped(dt)
end)