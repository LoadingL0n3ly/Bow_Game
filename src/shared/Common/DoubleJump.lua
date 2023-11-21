local class = {}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Player Info
local Player = game.Players.LocalPlayer
local Character
local Humanoid

-- Constants
local COOLDOWN = 0.1 -- seconds

-- Control Variables
local TimesClicked = 0
local theFirstTime = nil
local lastJump = os.time()


local function CharAdded(character: Model)
    Character = character
    Humanoid = Character:WaitForChild("Humanoid")
end

local function DetectDoubleTap(input: InputObject, gameProccess)
    if gameProccess then return end

    if input.KeyCode == Enum.KeyCode.Space and input.UserInputState == Enum.UserInputState.Begin then
        local state = Humanoid:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FallingDown then
            if os.time() - lastJump >= COOLDOWN then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJump = os.time()            
            end
        end
    end
end

function class.Setup()
    if Player.Character then CharAdded(Player.Character) end
    Player.CharacterAdded:Connect(CharAdded)

    UserInputService.InputBegan:Connect(DetectDoubleTap)
end



return class