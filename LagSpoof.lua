local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local LagSpoof = {}
local active = false
local conn = nil

local function toggle(UI)
	active = not active
	if active then
		local lastCF = nil
		local frame = 0
		conn = RunService.Heartbeat:Connect(function()
			local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			frame += 1
			if frame % 2 == 0 then
				if lastCF then hrp.CFrame = lastCF end
			else
				lastCF = hrp.CFrame
			end
		end)
		if UI then UI.Notify("Lag Spoof: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("Lag Spoof: OFF", "Warn") end
	end
end

function LagSpoof.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "lag" or cmd == "lagspoof" then toggle(UI) end
end

return LagSpoof
