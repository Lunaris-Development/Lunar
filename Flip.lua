local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local lp = Players.LocalPlayer
local Flip = {}

local function doFlip(forward, UI)
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end

	local axis = hrp.CFrame.RightVector

	hum.PlatformStand = true

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 85, 0)
	bv.MaxForce = Vector3.new(0, math.huge, 0)
	bv.Parent = hrp
	Debris:AddItem(bv, 0.17)

	local bav = Instance.new("BodyAngularVelocity")
	bav.AngularVelocity = axis * (forward and -24 or 24)
	bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bav.Parent = hrp
	Debris:AddItem(bav, 0.62)

	task.delay(0.72, function()
		local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
		if h then h.PlatformStand = false end
	end)

	if UI then UI.Notify((forward and "Front" or "Back") .. "flip!", "Success") end
end

function Flip.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "flip" or cmd == "frontflip" or cmd == "ff" then doFlip(true, UI)
	elseif cmd == "bflip" or cmd == "backflip" or cmd == "bf" then doFlip(false, UI)
	end
end

return Flip
