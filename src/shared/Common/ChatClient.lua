local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatMessageRemote = ReplicatedStorage.Remotes.ChatMessage

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

ChatMessageRemote.OnClientEvent:Connect(function(message: string, hex: string)
	task.wait(0.5)
	
	local channel: TextChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
	channel:DisplaySystemMessage("<font color='#" .. hex .. "'>"..message.."</font>")
end)

local RankData = {
	["1"] = {Text = "[Fan]", Color = "fa28d3"},
	["2"] = {Text = "[Tester]", Color = "2afc05"},
	["3"] = {Text = "[Alpha Tester]", Color = "fcbf05"},
	["254"] = {Text = "[Contributor]", Color = "b6fc05"},
	["255"] = {Text = "[Owner]", Color = "05aefc"},
}

function class.OnIncomingMessage(message: TextChatMessage)
	local props = Instance.new("TextChatMessageProperties")
	
	if message.TextSource then
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)
		local rank = player:GetRankInGroup(17235653)
		
		local PrefixData = RankData[tostring(rank)]
		
		if PrefixData then
			if rank > 0 then
				props.PrefixText = "<font color='#" .. PrefixData.Color .. "'>" .. PrefixData.Text .. "</font> " .. message.PrefixText
			end
		end
	end
	
	return props
end

return class
