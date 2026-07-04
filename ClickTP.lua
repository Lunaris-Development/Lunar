local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local ClickTP = {}
local active = false
local conn = nil

local function toggle(UI)
	active = not active
	if active then
		conn = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
			local isTouch = input.UserInputType == Enum.UserInputType.Touch
			if not isClick and not isTouch then return end
			local mousePos = UserInputService:GetMouseLocation()
			local ray = Workspace.CurrentCamera:ScreenPointToRay(mousePos.X, mousePos.Y)
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {lp.Character}
			params.FilterType = Enum.RaycastFilterType.Exclude
			local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			if result then
				local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
			end
		end)
		if UI then UI.Notify("ClickTP: ON", "Success") end
	else
		if conn then conn:Disconnect() conn = nil end
		if UI then UI.Notify("ClickTP: OFF", "Warn") end
	end
end

function ClickTP.HandleChat(msg, UI)
	local cmd = msg:lower():split(" ")[1]
	if cmd == "ftpmobile" or cmd == "clicktp" or cmd == "ctp" then toggle(UI) end
end

return ClickTP
