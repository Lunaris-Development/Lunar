local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local ShLow = {}

local function show(UI)
	local lowest = nil
	local lowestHp = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			if hum and hum.Health < lowestHp then
				lowestHp = hum.Health
				lowest = p
			end
		end
	end
	if lowest then
		print("[Lunar] Lowest HP: " .. lowest.Name .. " - " .. math.floor(lowestHp) .. "hp")
		if UI then UI.Notify("Lowest HP: " .. lowest.Name .. " (" .. math.floor(lowestHp) .. "hp)", "Warn") end
	else
		if UI then UI.Notify("No targets found", "Error") end
	end
end

function ShLow.HandleChat(msg, UI)
	if msg:lower():split(" ")[1] == "shlow" then show(UI) end
end

return ShLow
