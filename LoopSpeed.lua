local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local LoopSpeed = {}
local active = false
local speed = 50
local conn = nil

local function toggle(val, UI)
	if val then speed = val end
	active = not active
	if active then
		local function apply()
			local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
			if hum then hum.WalkSpeed = speed end
		end
		apply()
		conn = lp.CharacterAdded:Connect(function(char)
			char:WaitForChild("Humanoid").WalkSpeed = speed
		end)
		if UI then UI.Notify("LoopSpeed: " .. speed, "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
		if hum then hum.WalkSpeed = 16 end
		if UI then UI.Notify("LoopSpeed: OFF", "Warn") end
	end
end

function LoopSpeed.HandleChat(msg, UI)
	local parts = msg:lower():split(" ")
	if parts[1] == "loopspeed" or parts[1] == "lspeed" then
		toggle(tonumber(parts[2]), UI)
	end
end

return LoopSpeed
