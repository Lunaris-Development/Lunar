local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local Noclip = {}
local active = false
local conn = nil

local function toggle(UI)
	active = not active
	if active then
		conn = RunService.Stepped:Connect(function()
			local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CanCollide = false end
		end)
		if UI then UI.Notify("Noclip: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CanCollide = true end
		if UI then UI.Notify("Noclip: OFF", "Warn") end
	end
end

function Noclip.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "noclip" or cmd == "nc" then toggle(UI) end
end

return Noclip
