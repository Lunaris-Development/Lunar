local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local ShMost = {}

local function show(UI)
	local highest = nil
	local highestHp = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			if hum and hum.Health > highestHp then
				highestHp = hum.Health
				highest = p
			end
		end
	end
	if highest then
		print("[Lunar] Most HP: " .. highest.Name .. " - " .. math.floor(highestHp) .. "hp")
		if UI then UI.Notify("Most HP: " .. highest.Name .. " (" .. math.floor(highestHp) .. "hp)", "Success") end
	else
		if UI then UI.Notify("No targets found", "Error") end
	end
end

function ShMost.HandleChat(msg, UI)
	if msg:lower():split(" ")[1] == "shmost" then show(UI) end
end

return ShMost
