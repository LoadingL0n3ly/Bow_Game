local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage:WaitForChild("Common")

-- Modules
local BowClient = require(Common:WaitForChild("BowClient"))
local DoubleJump = require(Common:WaitForChild("DoubleJump"))


-- Setup
BowClient.Setup()
DoubleJump.Setup()