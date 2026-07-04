local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local AntiAFK = {}
local active = false
local conn = nil

local function toggle(UI)
	active = not active
	if active then
		conn = lp.Idled:Connect(function()
			VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(0.1)
			VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)
		if UI then UI.Notify("AntiAFK: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("AntiAFK: OFF", "Warn") end
	end
end

function AntiAFK.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "antiafk" or cmd == "afk" then toggle(UI) end
end

return AntiAFK
