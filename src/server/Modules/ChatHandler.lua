local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessageEvent = ReplicatedStorage.Remotes.ChatMessage

local JOIN_TEXT_COLOR = Color3.fromRGB(0, 255, 106):ToHex()
local LEAVE_TEXT_COLOR = Color3.fromRGB(255, 60, 60):ToHex()
local TIP_TEXT_COLOR = Color3.fromRGB(119, 119, 119):ToHex()


local Tips = {
	"Join our group to get a free permanent Rocket Launcher! 🚀",
    "Like and Favorite the game for Updates 📰",
    "Jump and Double-Tap with the sword equipped to do bonus damage!"
}

local LastTip0Id = -1
local LastTip1Id = -1
local function GetTip()
	local NextTipId = -1
	repeat
		NextTipId = math.random(1, #Tips)
	until NextTipId ~= LastTip0Id and NextTipId ~= LastTip1Id
	LastTip0Id = LastTip1Id
	LastTip1Id = NextTipId
	
	return NextTipId
end

function class.playerJoined(playerName)
	local message = "👋 - " .. playerName .. " just joined!"
	
	MessageEvent:FireAllClients(message, JOIN_TEXT_COLOR)
end

function class.playerLeft(playerName)
	local message = "🚪 - " .. playerName .. " just left!"

	MessageEvent:FireAllClients(message, LEAVE_TEXT_COLOR)
end

function class.sendMessage(message: string, hexMsgColor: string)
	MessageEvent:FireAllClients(message, hexMsgColor)
end


function class.sendTip()
	local selectedTip = Tips[GetTip()]
	class.sendMessage("[TIP] - " .. selectedTip, TIP_TEXT_COLOR)
end

return class
