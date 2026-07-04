local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local TouchFling = {}
local active = false
local charConn = nil

local function applySpin(hrp)
	if hrp:FindFirstChild("LunarSpin") then return end
	local bav = Instance.new("BodyAngularVelocity")
	bav.Name = "LunarSpin"
	bav.AngularVelocity = Vector3.new(0, 9999, 0)
	bav.MaxTorque = Vector3.new(0, math.huge, 0)
	bav.Parent = hrp
end

local function removeSpin(hrp)
	local bav = hrp:FindFirstChild("LunarSpin")
	if bav then bav:Destroy() end
end

local function toggle(UI)
	active = not active
	if active then
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then applySpin(hrp) end
		charConn = lp.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart")
			if active then applySpin(char.HumanoidRootPart) end
		end)
		if UI then UI.Notify("TouchFling: ON — walk into players", "Success") end
	else
		if charConn then charConn:Disconnect() charConn = nil end
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then removeSpin(hrp) end
		if UI then UI.Notify("TouchFling: OFF", "Warn") end
	end
end

function TouchFling.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "touchfling" or cmd == "tfling" then toggle(UI) end
end

return TouchFling
