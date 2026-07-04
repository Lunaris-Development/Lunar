local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local GodMode = {}
local active = false
local conn = nil
local charConn = nil

local function applyGod(char)
	local hum = char:WaitForChild("Humanoid")
	hum.MaxHealth = math.huge
	hum.Health = math.huge
	if conn then conn:Disconnect() end
	conn = hum.HealthChanged:Connect(function()
		if active then hum.Health = math.huge end
	end)
end

local function toggle(UI)
	active = not active
	if active then
		if lp.Character then applyGod(lp.Character) end
		charConn = lp.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			if active then applyGod(char) end
		end)
		if UI then UI.Notify("God Mode: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if charConn then charConn:Disconnect() charConn = nil end
		local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
		if hum then hum.MaxHealth = 100 hum.Health = 100 end
		if UI then UI.Notify("God Mode: OFF", "Warn") end
	end
end

function GodMode.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "god" or cmd == "godmode" then toggle(UI) end
end

return GodMode
