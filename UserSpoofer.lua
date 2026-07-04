local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local UserSpoofer = {}

local function spoof(name, UI)
	pcall(function() lp.DisplayName = name end)
	if UI then UI.Notify("Spoofed: " .. name, "Success") end
end

function UserSpoofer.HandleChat(msg, UI)
	local parts = msg:lower():split(" ")
	if parts[1] == "userspoofer" or parts[1] == "spoof" then
		spoof(parts[2] or "player", UI)
	end
end

return UserSpoofer
