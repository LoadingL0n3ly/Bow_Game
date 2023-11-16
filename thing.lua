local class = {}
local TweenService = game:GetService("TweenService")

-- Frames Opening Animations -- also used for health appearing and dissapearing
function class.FrameOpen(frame: Frame)
	local size = frame.Size 
	frame.Visible = true
	frame.Size = UDim2.fromScale(0,0)
	print("Tick")

	local scaleUp = TweenService:Create(frame, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {Size = size})
	scaleUp:Play()
end

function class.FrameClose(obj: Frame)
	local size = obj.Size 
	obj.Visible = true

	local scaleDown = TweenService:Create(obj, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {Size = UDim2.fromScale(0,0)})
	scaleDown:Play()

	scaleDown.Completed:Connect(function()
		obj.Visible = false
		obj.Size = size
	end)
end

-- Storage Item Added
function class.ItemAdded(obj: Frame)
	local size = obj.Size 
	local pos = obj.Position

	obj.Visible = true
	obj.Size = UDim2.fromScale(0,0)
	obj.Position = UDim2.fromScale(pos.X.Scale, pos.Y.Scale + size.Y.Scale * 0.1)

	TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = pos}):Play()
	TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = size}):Play()
end

-- Tab Switch 
function class.TabSwitch(obj: ImageButton)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local mT = TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.fromScale(pos.X.Scale, pos.Y.Scale - 0.05)})
	local mR = TweenService:Create(obj, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {Rotation = rot + 5})
	mT:Play()
	mR:Play()

	mR.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {Rotation = rot}):Play()
	end)

	mT.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = size}):Play()
	end)
end

-- Add Button CLick
function class.AddClick(obj: ImageButton)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local uS = TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(size.X.Scale * 1.5, size.Y.Scale * 1.5)})
	uS:Play()

	uS.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Size = size}):Play()
	end)
end

-- Subtract Button Click
function class.SubtractClick(obj: ImageButton)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local uS = TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(size.X.Scale * 0.5, size.Y.Scale * 0.5)})
	uS:Play()

	uS.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Size = size}):Play()
	end)
end

-- Purchase Button Click
function class.PurchaseButtonClick(obj: ImageButton)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local uS = TweenService:Create(obj, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(size.X.Scale * 1.2, size.Y.Scale * 1.2)})
	uS:Play()

	TweenService:Create(obj, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, true), {Rotation = 360}):Play()

	uS.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {Size = size}):Play()
	end)
end

-- Standard Hover
function class.ButtonHoverSetup(obj: ImageButton)
	if obj:GetAttribute("Setup") then return end
	obj:SetAttribute("Setup", true)

	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position


	obj.MouseEnter:Connect(function()
		local uS = TweenService:Create(obj, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromScale(size.X.Scale * 1.2, size.Y.Scale * 1.2)})
		uS:Play()
	end)

	obj.MouseLeave:Connect(function()
		local dS = TweenService:Create(obj, TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), {Size = size})
		dS:Play()
	end)
end


-- Standard Button Click
function class.ButtonClick(obj: ImageButton)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local uS = TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(size.X.Scale * 1.2, size.Y.Scale * 1.2)})
	uS:Play()

	uS.Completed:Connect(function()
		TweenService:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), {Size = size}):Play()
	end)
end

function class.DialoguePopIn(obj: Frame)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	obj.Position = UDim2.fromScale(0.5, 1.5)
	obj.Size = UDim2.fromScale(size.X.Scale * 0.4, size.Y.Scale)
	obj.Visible = true
	TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = pos, Size = size}):Play()
end

function class.DialoguePopOut(obj: Frame)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position

	local tween = TweenService:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 1.5), Size = UDim2.fromScale(size.X.Scale * 0.4, size.Y.Scale)})
	tween:Play()

	tween.Completed:Connect(function()
		obj.Visible = false
		obj.Position = pos
		obj.Size = size
	end)
end

function class.MissionAppear(obj: Frame)
	local size = obj.Size
	local rot = obj.Rotation
	local pos = obj.Position
	local transparency = 0.1

	obj.Size = UDim2.fromScale(0,0)
	obj.BackgroundTransparency = 1
	obj.Visible = true

	local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = size})
	tween:Play()

	TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = transparency}):Play()
end

function class.MissionComplete(obj: Frame)
	local size = obj.Size
	local transparency = 0.1
	local color = obj.BackgroundColor3

	local colorTween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundColor3 = Color3.fromRGB(5, 63, 17)})
	colorTween:Play()

	-- local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(0,0)})
	-- tween:Play()

	-- TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

	-- tween.Completed:Connect(function()
	-- 	obj.Visible = false
	-- 	obj.Size = size
	-- 	obj.BackgroundTransparency = transparency
	-- 	obj.BackgroundColor3 = color
	-- end)
end

function class.MissionFailed(obj: Frame)
	local size = obj.Size
	local transparency = 0.1
	local color = obj.BackgroundColor3

	local colorTween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundColor3 = Color3.fromRGB(63, 9, 5)})
	colorTween:Play()
	-- colorTween.Completed:Wait()

	-- local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromScale(0,0)})
	-- tween:Play()

	-- TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

	-- tween.Completed:Connect(function()
	-- 	obj.Visible = false
	-- 	obj.Size = size
	-- 	obj.BackgroundTransparency = transparency
	-- 	obj.BackgroundColor3 = color
	-- end)
end

-- Notification Appear
function class.NotificationAppear(obj: CanvasGroup)
    local transparency = obj.GroupTransparency

    obj.GroupTransparency = 1
    obj.Visible = true

    local transparencyTween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 0})
    transparencyTween:Play()
end

function class.NotificationDisappear(obj: CanvasGroup)
    local transparency = obj.GroupTransparency

    local transparencyTween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
    transparencyTween:Play()

    transparencyTween.Completed:Connect(function()
        obj.Visible = false
        obj.GroupTransparency = transparency
    end)
end



return class
