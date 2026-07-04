local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local InfJump = {}
local active = false
local conn = nil

local function toggle(UI)
	active = not active
	if active then
		conn = UserInputService.JumpRequest:Connect(function()
			if not active then return end
			local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
		if UI then UI.Notify("Inf Jump: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("Inf Jump: OFF", "Warn") end
	end
end

function InfJump.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "infjump" or cmd == "ij" then toggle(UI) end
end

return InfJump
