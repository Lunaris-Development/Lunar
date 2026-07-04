local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local WalkOnAir = {}
local active = false
local bp = nil
local conn = nil

local function toggle(UI)
	active = not active
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then active = false return end
	if active then
		bp = Instance.new("BodyPosition")
		bp.Position = hrp.Position
		bp.MaxForce = Vector3.new(0, math.huge, 0)
		bp.D = 1000
		bp.P = 10000
		bp.Parent = hrp
		conn = RunService.Heartbeat:Connect(function()
			local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
			if not h or not bp then return end
			if h.Position.Y > bp.Position.Y + 0.5 then
				bp.Position = Vector3.new(bp.Position.X, h.Position.Y, bp.Position.Z)
			end
		end)
		if UI then UI.Notify("Walk on Air: ON", "Success") end
	else
		if bp then bp:Destroy() bp = nil end
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("Walk on Air: OFF", "Warn") end
	end
end

function WalkOnAir.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "walkair" or cmd == "wa" or cmd == "walkonair" then toggle(UI) end
end

return WalkOnAir
