local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local PlayerTP = {}

local function tpTo(name, UI)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Name:lower():find(name:lower(), 1, true) then
			local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if tHrp and myHrp then
				myHrp.CFrame = tHrp.CFrame * CFrame.new(3, 0, 0)
				if UI then UI.Notify("TP -> " .. p.Name, "Success") end
			else
				if UI then UI.Notify("Character not found", "Error") end
			end
			return
		end
	end
	if UI then UI.Notify("Player not found: " .. name, "Error") end
end

local function listPlayers(UI)
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then table.insert(names, p.Name) end
	end
	print("[Lunar] Players: " .. (next(names) and table.concat(names, ", ") or "none"))
	if UI then UI.Notify(#names .. " player(s) in console", "Success") end
end

function PlayerTP.HandleChat(msg, UI)
	local parts = msg:lower():split(" ")
	local cmd = parts[1]
	if cmd == "tp" then
		if parts[2] then tpTo(parts[2], UI) else listPlayers(UI) end
	end
end

return PlayerTP
