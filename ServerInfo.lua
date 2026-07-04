local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local ServerInfo = {}

function ServerInfo.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "serverinfo" or cmd == "sinfo" then
		if UI and UI.ToggleServerInfo then
			UI.ToggleServerInfo()
		else
			local count = #Players:GetPlayers()
			local ping = math.floor(lp:GetNetworkPing() * 1000)
			local age = math.floor(workspace.DistributedGameTime / 60)
			print("[Lunar] Players: " .. count .. " | Ping: " .. ping .. "ms | Age: " .. age .. "m | ID: " .. game.JobId)
		end
	end
end

return ServerInfo
