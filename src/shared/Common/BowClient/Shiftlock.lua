local class = {}

local Player = game.Players.LocalPlayer

local CameraAngleX = 0
local CameraAngleY = 0


function class.ShiftLock(Active)
	local Character = Player.Character
	if not Character then print("Shiftlock couldn't fix character!") return end

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid") 
	if not Humanoid.RootPart then warn("Shiftlock couldn't find RootPart") return end

	local Crosshair = Player.PlayerGui:FindFirstChild("Main"):FindFirstChild("Crosshair")

	if Active then
		Humanoid.AutoRotate = false
		
		Humanoid.RootPart.CFrame = Humanoid.RootPart.CFrame:Lerp(CFrame.new(Humanoid.RootPart.Position, Humanoid.RootPart.Position + Vector3.new(workspace.CurrentCamera.CFrame.LookVector.X, 0 , workspace.CurrentCamera.CFrame.LookVector.Z)), 0.3) 
		game:GetService("RunService"):BindToRenderStep("ShiftLock", Enum.RenderPriority.Camera.Value, function()
			Humanoid.RootPart.CFrame = Humanoid.RootPart.CFrame:Lerp(CFrame.new(Humanoid.RootPart.Position, Humanoid.RootPart.Position + Vector3.new(workspace.CurrentCamera.CFrame.LookVector.X, 0 , workspace.CurrentCamera.CFrame.LookVector.Z)), 0.3) 
			Humanoid.AutoRotate = false
			
			local ZoomMagnitude = (math.abs((workspace.CurrentCamera.CFrame.Position - Character.Head.Position).Magnitude))

			local startCFrame = workspace.CurrentCamera.CFrame
			local cameraCFrame = startCFrame:ToWorldSpace(CFrame.new(3.5, 1, (ZoomMagnitude/20)-0.5))
			local cameraFocus = startCFrame:ToWorldSpace(CFrame.new(3.5, 1, -10000))
			workspace.CurrentCamera.CFrame = CFrame.new(cameraCFrame.Position, cameraFocus.Position)
			game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
			game:GetService("UserInputService").MouseIconEnabled = false

			Crosshair.Visible = true
		end)
	else
		Humanoid.AutoRotate = true
		game:GetService("RunService"):UnbindFromRenderStep("ShiftLock")
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
		game:GetService("UserInputService").MouseIconEnabled = true
		Crosshair.Visible = false
	end
end


return class
