local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local AimLock = {}
local active = false
local conn = nil

local function getNearest()
	local closest, closestDist = nil, math.huge
	local camPos = Camera.CFrame.Position
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (hrp.Position - camPos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = p
				end
			end
		end
	end
	return closest
end

local function toggle(UI)
	active = not active
	if active then
		conn = RunService.RenderStepped:Connect(function()
			if not active then return end
			local target = getNearest()
			if target and target.Character then
				local hrp = target.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position + Vector3.new(0, 1.5, 0))
				end
			end
		end)
		if UI then UI.Notify("Aim Lock: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("Aim Lock: OFF", "Warn") end
	end
end

function AimLock.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "aimlock" or cmd == "al" then toggle(UI) end
end

return AimLock
