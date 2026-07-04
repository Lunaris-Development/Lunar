local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local lp = Players.LocalPlayer
local Reach = {}
local active = false
local reachDist = 20
local conn = nil

local function toggle(dist, UI)
	if dist then reachDist = dist end
	active = not active
	if active then
		conn = RunService.Heartbeat:Connect(function()
			local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= lp and p.Character then
					local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
					if tHrp and (tHrp.Position - hrp.Position).Magnitude <= reachDist then
						local bv = Instance.new("BodyVelocity")
						bv.Velocity = (tHrp.Position - hrp.Position).Unit * 180 + Vector3.new(0, 80, 0)
						bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bv.Parent = tHrp
						Debris:AddItem(bv, 0.12)
					end
				end
			end
		end)
		if UI then UI.Notify("Reach: ON (" .. reachDist .. " studs)", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("Reach: OFF", "Warn") end
	end
end

function Reach.HandleChat(msg, UI)
	local parts = msg:lower():split(" ")
	if parts[1] == "reach" then toggle(tonumber(parts[2]), UI) end
end

return Reach
