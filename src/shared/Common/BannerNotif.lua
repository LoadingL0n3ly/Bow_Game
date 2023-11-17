local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local info = TweenInfo.new(.5, Enum.EasingStyle.Exponential)

local notifyEvent = replicatedStorage:WaitForChild("Remotes"):WaitForChild("BannerNotify")

local default = {
	.3, 							-- Background Transparency
	Color3.new(0.549019, 0.933333, 0.470588), 		-- Background Color
	
	0, 								-- Content Transparency
	Color3.new(255, 255, 255), 	-- Content Color
}

local module = {}

function module:Notify(header, description, icon, duration, configs, player)
	if runService:IsClient() then
		local ui = players.LocalPlayer.PlayerGui:WaitForChild("BannerNotification")

		local activeFrame = ui.ActiveNotifications
		local canvasTemplate = ui.Canvas
		local notif = canvasTemplate:Clone()
		
		--// set up
		
		notif.Name = header
		notif.Parent = activeFrame
		
		notif.Notification.Texts.Header.Text = header
		notif.Notification.Texts.Description.Text = description
		notif.Notification.Icon.Image = icon
		
		notif.Notification.ImageTransparency = 1
		notif.Notification.Icon.ImageTransparency = 1
		notif.Notification.Texts.GroupTransparency = 1
				
		notif.Shape.ImageColor3 = (configs and configs[2]) or default[2]
		notif.Notification.Texts.GroupColor3 = (configs and configs[4]) or default[4]
		notif.Notification.Icon.ImageColor3 = (configs and configs[4]) or default[4]

		notif.Visible = true

		--// animation initiation
		
		notif.Shape.Scale.Scale = 0
		notif.Shape.ImageTransparency = 1

		tweenService:Create(notif.Shape, info, {ImageTransparency = (configs and configs[1]) or default[1]}):Play()
		tweenService:Create(notif.Shape.Scale, info, {Scale = 1.2}):Play()
		
		----------------

		task.wait(.3)
		
		--// transformed the shape to circle

		notif.Shape.Image = "rbxassetid://11942813307"

		tweenService:Create(notif.Shape, info, {Size = UDim2.fromOffset(notif.Notification.AbsoluteSize.X, notif.Notification.AbsoluteSize.Y)
			}):Play()
		tweenService:Create(notif.Shape.Scale, info, {Scale = 1}):Play()
		
		----------------

		task.wait(.1)

		----------------
		
		tweenService:Create(notif.Notification.Texts, info, {GroupTransparency = (configs and configs[3]) or default[3]}):Play()
		tweenService:Create(notif.Notification.Icon, info, {ImageTransparency = (configs and configs[3]) or default[3]}):Play()
		
		--// duration started

		task.wait(duration)

		--// duration ended

		tweenService:Create(notif.Notification.Texts, info, {GroupTransparency = 1}):Play()
		tweenService:Create(notif.Notification.Icon, info, {ImageTransparency = 1}):Play()
		
		----------------

		task.wait(.2)
		
		--// transformed the shape back to circle

		notif.Shape.Image = "rbxassetid://11983017276" -- circle

		tweenService:Create(notif.Shape, info, {Size = UDim2.fromOffset(60, 60), 
			ImageTransparency = (configs and configs[1]) or default[1]}):Play()
		
		tweenService:Create(notif.Shape.Scale, info, {Scale = 1.2}):Play()
		
		----------------
		
		task.wait(.3)
		
		----------------

		tweenService:Create(notif.Shape, info, {ImageTransparency = 1}):Play()
		tweenService:Create(notif.Shape.Scale, info, {Scale = 0}):Play()
		
		----------------

		task.wait(.3)
		
		----------------
		
		tweenService:Create(notif.Padding, info, {PaddingTop = UDim.new(0, 0)}):Play()
		tweenService:Create(notif.Padding, info, {PaddingBottom = UDim.new(0, 0)}):Play()

		tweenService:Create(notif.Notification.Scale, info, {Scale = 0}):Play()
		
		----------------

		task.wait(.3)

		----------------

		notif:Destroy()

	elseif runService:IsServer() then
		notifyEvent:FireClient(player, header, description, icon, duration, configs, default)
	end
end

function module.NumberOfActiveNotifications(player)
	if runService:IsClient() then
		local notificationUi = game.Players.LocalPlayer.PlayerGui:WaitForChild("BannerNotification")
		local activatedFolder = notificationUi.ActiveNotifications

		for i, notifs in pairs(activatedFolder:GetChildren()) do
			local actualNum = #notifs - 2

			return actualNum
		end
	elseif runService:IsServer() then
		local notificationUi = player.PlayerGui:WaitForChild("BannerNotification")
		local activatedFolder = notificationUi.ActiveNotifications

		for i, notifs in pairs(activatedFolder:GetChildren()) do
			local actualNum = #notifs - 2

			return actualNum
		end
	end
end

return module